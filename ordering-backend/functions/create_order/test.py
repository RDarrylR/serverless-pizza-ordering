
import os
from datetime import datetime, UTC
from decimal import Decimal
from typing import Dict, Any
from datetime import timedelta

import traceback
from momento.responses import (
    CacheDelete,
    CacheGet,
    CacheSet,
    CreateCache,
    DeleteCache,
    ListCaches,
    TopicPublish,
    TopicSubscribe,
    TopicSubscriptionItem,
    GenerateDisposableToken,
)
from momento.utilities import ExpiresIn
from momento import AuthClient
from momento.auth.access_control.disposable_token_scopes import DisposableTokenScopes

from momento.responses import CacheGet

from momento import (
    Configurations,
    CredentialProvider
)
api_key = "eyJlbmRwb2ludCI6ImNlbGwtdXMtZWFzdC0xLTEucHJvZC5hLm1vbWVudG9ocS5jb20iLCJhcGlfa2V5IjoiZXlKaGJHY2lPaUpJVXpJMU5pSjkuZXlKemRXSWlPaUprWVhKeWVXeEFjblZuWjJ4bGN5NWpiRzkxWkNJc0luWmxjaUk2TVN3aWNDSTZJa05CUVQwaWZRLnR1S09icEZsQ1FhZEhNMUc3LUJraTdIMmlXb0U5R21BMHJZVGJNQi05ckUifQ=="

try:
    momento_api_key = CredentialProvider.from_string(api_key)
    ttl  = timedelta(seconds=int(os.getenv('MOMENTO_TTL_SECONDS', '600')))

    auth_client = AuthClient(
        Configurations.Lambda.latest(),
        CredentialProvider.from_string(api_key)
    )
    response = auth_client.generate_disposable_token(
                DisposableTokenScopes.topic_publish_subscribe("pizza-orders", "order-"),
                ExpiresIn.minutes(5))
    match response:
        case GenerateDisposableToken.Success():
            print("Successfully generated a disposable token")
            print(response.auth_token)
            print(response.endpoint)
            print(response.expires_at.datetime)
        case GenerateDisposableToken.Error() as error:
            print(f"Error generating a disposable token: {error.message}")    
    
except Exception as e:
    traceback.print_exc()
    print(f"traceback={traceback.format_exc()}")


