from channels.generic.websocket import WebsocketConsumer
from channels.exceptions import StopConsumer
from asgiref.sync import async_to_sync

class ChatConsumer(WebsocketConsumer):
    def websocket_connect(self, message):
        print("connect")
        self.accept()
    
    def websocket_receive(self, message):
        print(message)
        self.send("hello")
    
    def websocket_disconnect(self, message):
        raise StopConsumer()