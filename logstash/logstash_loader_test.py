import os
import json
import requests

class logstash:

    def __init__(self):
        pass

    def ReadData(self, inputDir):
        os.chdir(inputDir)
        fileNames = os.listdir(inputDir)

        no = 0
        sizFileNames = len(fileNames)
        for fileName in fileNames:
            no += 1
            print('[{0:03d}/{1}]\t'.format(no, sizFileNames) + fileName + ': Start...', end='')
            # if no <= 237:
            #     continue
            jsonData = json.loads(open(fileName, 'r').read())
            length = len(jsonData)

            for i in range(0, length, 100000):
                if i + 100000 >= length:
                    data = jsonData[i:]
                else:
                    data = jsonData[i:i + 100000]

                while True:
                    try:
                        res = requests.post('http://localhost:5006', json=data)
                        print(res.text, end='')
                        if res.text != 'ok':
                            print('{0}:{1}'.format(res.status_code, res.reason), end='')
                        break
                    except requests.exceptions.Timeout:
                        print('retry', end='')

                    except:
                        print('{0}:{1}'.format(res.status_code, res.reason), end='')
                        print('retry', end='')
            print()


if __name__ == "__main__":
    dirJsonData = 'D:/script/Window/result/'

    log = logstash()
    log.ReadData(dirJsonData + '2022-1.json')
    log.ReadData(dirJsonData + '2022-2.json')
    log.ReadData(dirJsonData + '2023-1.json')
    log.ReadData(dirJsonData + '2023-2.json')
    log.ReadData(dirJsonData + '2024-1.json')
    log.ReadData(dirJsonData + '2024-2.json')
