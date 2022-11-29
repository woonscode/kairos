import json
import requests
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from rest_framework.decorators import api_view

# URL removed for partner privacy purposes
url = ""

@csrf_exempt
@api_view(['POST'])
def sso_login(request):
    if request.method == 'POST':
        json_data = json.loads(str(request.body, encoding='utf-8'))
        return_data = requests.post(
            url + "/token",
            json_data["data"]
        )
        return JsonResponse(return_data.json())
    else:
        return JsonResponse({"error": "Incorrect HTTP Method"})

@csrf_exempt
@api_view(['POST'])
def sso_userdata(request):
    if request.method == 'POST':
        json_data = json.loads(str(request.body, encoding='utf-8'))
        return_data = requests.get(
            url + "/userinfo",
            headers={'Authorization': "Bearer " + json_data["authorization"] }
        )
        return JsonResponse(return_data.json())
    else:
        return JsonResponse({"error": "Incorrect HTTP Method"})