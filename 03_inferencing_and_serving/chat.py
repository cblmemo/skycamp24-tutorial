import json

import requests

stream = True
model = 'meta-llama/Llama-3.1-8B-Instruct'
history = [{'role': 'system', 'content': 'You are a helpful assistant.'}]
endpoint = input('Endpoint: ')
url = f'http://{endpoint}/v1/chat/completions'

try:
    while True:
        user_input = input('[User] ')
        history.append({'role': 'user', 'content': user_input})
        response = requests.post(
            url,
            data=json.dumps({
                'model': model,
                'messages': history,
                'stream': True
            }),
            stream=True,
        )

        print('[Chatbot]', end=' ', flush=True)
        tot = ''
        for line in response.iter_lines():
            if line:
                if not isinstance(line, str):
                    line = line.decode('utf-8')
                line = line.strip().strip('data: ')

                try:
                    json_data = json.loads(line)
                    dlt = json_data['choices'][0]['delta']
                    if 'content' in dlt:
                        print(dlt['content'], end='', flush=True)
                        tot += dlt['content']
                except json.JSONDecodeError:
                    continue
        print()
        history.append({'role': 'assistant', 'content': tot})
except KeyboardInterrupt:
    print('\nBye!')
