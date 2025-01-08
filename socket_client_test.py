import socket
import zipfile
import os
import subprocess  # 명령어 실행을 위한 모듈
import time

def receive_file(client_socket, save_path, file_size):
    """서버에서 파일을 수신하여 지정된 경로에 저장"""
    received_size = 0  # 수신한 크기 초기화
    with open(save_path, 'wb') as f:
        while received_size < file_size:
            data = client_socket.recv(min(1024, file_size - received_size))
            if not data:
                break
            f.write(data)
            received_size += len(data)  # 수신한 크기 업데이트
    print(f"File received successfully. Total received size: {received_size} bytes.")

def unzip_file(zip_path, extract_to):
    """압축 파일을 지정된 경로에 해제"""
    with zipfile.ZipFile(zip_path, 'r') as zip_ref:
        zip_ref.extractall(extract_to)
    print(f"Files extracted to {extract_to}")

def delete_file(file_path):
    """파일 삭제"""
    if os.path.exists(file_path):
        os.remove(file_path)
        print(f"Deleted file: {file_path}")
    else:
        print(f"File not found: {file_path}")

def execute_command(command):
    """명령어를 실행하고 결과를 반환"""
    try:
        result = subprocess.run(command, shell=True, capture_output=True, text=True)
        output = result.stdout + result.stderr
        print(f"Command output:\n{output}")
        return output
    except Exception as e:
        print(f"Command execution error: {e}")
        return str(e)

def start_client():
    server_ip = input("Enter the server IP address: ")
    server_port = 10000
    client_id = input("Enter your client ID: ")
    current_directory = os.getcwd()
    save_path = os.path.join(current_directory, 'received_folder.zip')
    extract_to = current_directory

    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as client_socket:
        try:
            client_socket.connect((server_ip, server_port))
            client_socket.sendall(client_id.encode())  # 클라이언트 ID 전송

            while True:
                command = client_socket.recv(1024)
                print(f"Received raw command: {command}")  # 수신된 원시 데이터 출력
                command = command.decode('utf-8')
                # print(command)
                if not command:
                    print("Connection closed by the server.")
                    break

                if command.startswith("FILE_TRANSFER"):
                    # 공백을 기준으로 명령어와 파일 크기 분리
                    parts = command.split()
                    data = parts[0]  # FILE_TRANSFER 명령어
                    file_size = int(parts[1])  # 파일 크기

                if data == "FILE_TRANSFER":
                    client_socket.sendall(b"OK")
                    time.sleep(1)
                    # 파일 전송 모드로 전환
                    receive_file(client_socket, save_path, file_size)
                    unzip_file(save_path, extract_to)
                    delete_file(save_path)

                elif command.startswith("EXECUTE"):
                    # 명령어 실행
                    exec_command = command.split("EXECUTE ", 1)[1]
                    print(f"Executing command: {exec_command}")
                    output = execute_command(exec_command)
                    # 명령어 결과 전송
                    if output:
                        # 데이터 크기 전송
                        data = output.encode('utf-8')
                        client_socket.sendall(str(len(data)).encode('utf-8'))  # 데이터 길이를 먼저 전송
                        client_socket.recv(1)  # 서버로부터 수신 확인
                        client_socket.sendall(data)  # 실제 데이터 전송
                    else:
                        client_socket.sendall(b"0")  # 데이터 크기 0 전송

                elif command == "SERVER_SHUTDOWN":
                    print("Server is shutting down. Closing connection.")
                    break

                else:
                    print(f"Unknown command: {command}")

        except Exception as e:
            print(f"An error occurred: {e}")

if __name__ == "__main__":
    start_client()
