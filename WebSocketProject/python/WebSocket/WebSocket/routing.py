from django.urls import re_path
from app import consumers

websocket_urlpatterns = [
    re_path(r'ws/(?P<group>\w+)/$', consumers.ChatConsumer.as_asgi()),
]
