import socket
import zipfile
import os
import threading
import atexit  # atexit 모듈 추가
import time

clients = []  # 연결된 클라이언트 목록
server_running = True  # 서버 상태 확인용 변수

def zip_folder(folder_path, zip_path):
    with zipfile.ZipFile(zip_path, 'w') as zipf:
        for root, dirs, files in os.walk(folder_path):
            for file in files:
                file_path = os.path.join(root, file)
                zipf.write(file_path, os.path.relpath(file_path, folder_path))

def send_file(conn, file_path):
    try:
        file_size = os.path.getsize(file_path)  # 파일 크기 가져오기
        print(file_size)
        conn.sendall(b"FILE_TRANSFER " + str(file_size).encode())  # 파일 전송 명령 전송

        # 명령어 전송 후 지연
        time.sleep(1)  # 1초 지연 (필요에 따라 조정 가능)
        
        with open(file_path, 'rb') as f:
            data = f.read()
            conn.sendall(data)
            print("파일 전송 성공.")
    except Exception as e:
        print(f"파일 전송 오류: {e}")

def handle_client(conn, addr):
    client_id = conn.recv(1024).decode()
    print(f"Connected by {addr} with ID: {client_id}")
    clients.append((conn, addr, client_id))  # 클라이언트를 목록에 추가

    while server_running:
        try:
            command = conn.recv(1024).decode()
            if not command:  # If no command received, break
                print(f"Client {addr} has disconnected.")
                break
            
            if command == 'DISCONNECT':
                print(f"Client {addr} disconnected.")
                break
            elif command.startswith("EXECUTE"):
                print(f"Received command from {addr}: {command}")
            else:
                print(f"Unknown command from {addr}: {command}")
        except Exception as e:
            print(f"Error with client {addr}: {e}")
            break
    clients.remove((conn, addr, client_id))  # 클라이언트를 목록에서 제거
    conn.close()

def start_server(host='0.0.0.0', port=10000):
    global server_running
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as server_socket:
        server_socket.bind((host, port))
        server_socket.listen(5)
        print(f"Server listening on {host}:{port}")
        
        while server_running:  # 여러 클라이언트 처리
            try:
                conn, addr = server_socket.accept()
                client_thread = threading.Thread(target=handle_client, args=(conn, addr))
                client_thread.start()  # 새로운 클라이언트에 대한 쓰레드 시작
            except Exception as e:
                print(f"서버 오류: {e}")
                break

def send_file_to_client(client_index, folder_path):
    if 0 <= client_index < len(clients):
        conn, addr, client_id = clients[client_index]
        zip_path = './compressed_folder.zip'
        
        if os.path.isdir(folder_path):
            zip_folder(folder_path, zip_path)
            send_file(conn, zip_path)
            delete_file(zip_path)
        else:
            print("Invalid folder path.")
    else:
        print("Invalid client index.")

def delete_file(file_path):
    if os.path.exists(file_path):
        os.remove(file_path)
        print(f"Deleted file: {file_path}")
    else:
        print(f"File not found: {file_path}")

def show_connected_clients():
    if clients:
        print("Connected clients:")
        for index, (_, addr, client_id) in enumerate(clients):
            print(f"{index+1}: {addr} (ID: {client_id})")
    else:
        print("No connected clients.")

def shutdown_server():
    global server_running
    server_running = False
    print("모든 클라이언트와의 연결을 종료합니다.")
    for conn, addr, client_id in clients:
        try:
            conn.sendall(b"SERVER_SHUTDOWN")  # 서버 종료 메시지 전송
            conn.close()  # 클라이언트 연결 종료
            print(f"{addr} (ID: {client_id})와의 연결을 종료했습니다.")
        except Exception as e:
            print(f"{addr} (ID: {client_id}) 연결 종료 오류: {e}")

def send_command_to_execute(client_index, file_name):
    if 0 <= client_index < len(clients):
        conn, addr, client_id = clients[client_index]
        try:
            command = f"EXECUTE {file_name}"
            conn.sendall(command.encode())  # 클라이언트로 명령 전송
            print(f"명령 '{command}'를 {addr} (ID: {client_id})로 전송했습니다.")
        except Exception as e:
            print(f"명령 전송 오류: {e}")
    else:
        print("Invalid client index.")

# 프로그램 종료 시 클라이언트 연결 종료를 위한 함수 등록
atexit.register(shutdown_server)

if __name__ == "__main__":
    try:
        server_thread = threading.Thread(target=start_server)
        server_thread.start()

        while True:
            print("\nMenu:")
            print("1. 연결된 클라이언트 목록 보기")
            print("2. 파일 또는 디렉터리 전송")
            print("3. 클라이언트에서 파일 실행")
            print("4. 서버 종료")
            choice = input("옵션을 선택하세요: ").strip()

            if choice == '1':
                show_connected_clients()

            elif choice == '2':
                if not clients:
                    print("전송할 클라이언트가 없습니다.")
                    continue
                
                show_connected_clients()
                client_index = int(input(f"\n파일을 전송할 클라이언트를 선택하세요: ")) - 1
                
                folder_path = input("전송할 디렉터리의 경로를 입력하세요: ").strip()
                send_file_to_client(client_index, folder_path)

            elif choice == '3':
                if not clients:
                    print("실행할 클라이언트가 없습니다.")
                    continue
                
                show_connected_clients()
                client_index = int(input(f"\n파일을 실행할 클라이언트를 선택하세요: ")) - 1
                
                file_name = input("실행할 명령어를 입력하세요: ").strip()
                send_command_to_execute(client_index, file_name)

            elif choice == '4':
                print("서버를 종료합니다.")
                shutdown_server()  # 모든 클라이언트와 연결 종료
                break

            else:
                print("잘못된 옵션입니다.")

    except KeyboardInterrupt:
        print("\n서버를 강제로 종료합니다.")
