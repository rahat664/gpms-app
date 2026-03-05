# BuyersApi

All URIs are relative to *http://localhost*

| Method | HTTP request | Description |
|------------- | ------------- | -------------|
| [**buyersControllerCreate**](BuyersApi.md#buyersControllerCreate) | **POST** /api/buyers | Create a buyer in the selected factory |
| [**buyersControllerFindAll**](BuyersApi.md#buyersControllerFindAll) | **GET** /api/buyers | List buyers for the selected factory |
| [**buyersControllerRemove**](BuyersApi.md#buyersControllerRemove) | **DELETE** /api/buyers/{id} | Delete a buyer from the selected factory |
| [**buyersControllerUpdate**](BuyersApi.md#buyersControllerUpdate) | **PUT** /api/buyers/{id} | Update a buyer in the selected factory |


<a id="buyersControllerCreate"></a>
# **buyersControllerCreate**
> buyersControllerCreate(xFactoryId, createBuyerDto)

Create a buyer in the selected factory

### Example
```java
// Import classes:
import org.openapitools.client.ApiClient;
import org.openapitools.client.ApiException;
import org.openapitools.client.Configuration;
import org.openapitools.client.models.*;
import org.openapitools.client.api.BuyersApi;

public class Example {
  public static void main(String[] args) {
    ApiClient defaultClient = Configuration.getDefaultApiClient();
    defaultClient.setBasePath("http://localhost");

    BuyersApi apiInstance = new BuyersApi(defaultClient);
    String xFactoryId = "xFactoryId_example"; // String | Factory UUID selected for the request scope
    CreateBuyerDto createBuyerDto = new CreateBuyerDto(); // CreateBuyerDto | 
    try {
      apiInstance.buyersControllerCreate(xFactoryId, createBuyerDto);
    } catch (ApiException e) {
      System.err.println("Exception when calling BuyersApi#buyersControllerCreate");
      System.err.println("Status code: " + e.getCode());
      System.err.println("Reason: " + e.getResponseBody());
      System.err.println("Response headers: " + e.getResponseHeaders());
      e.printStackTrace();
    }
  }
}
```

### Parameters

| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **xFactoryId** | **String**| Factory UUID selected for the request scope | |
| **createBuyerDto** | [**CreateBuyerDto**](CreateBuyerDto.md)|  | |

### Return type

null (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **201** |  |  -  |

<a id="buyersControllerFindAll"></a>
# **buyersControllerFindAll**
> buyersControllerFindAll(xFactoryId)

List buyers for the selected factory

### Example
```java
// Import classes:
import org.openapitools.client.ApiClient;
import org.openapitools.client.ApiException;
import org.openapitools.client.Configuration;
import org.openapitools.client.models.*;
import org.openapitools.client.api.BuyersApi;

public class Example {
  public static void main(String[] args) {
    ApiClient defaultClient = Configuration.getDefaultApiClient();
    defaultClient.setBasePath("http://localhost");

    BuyersApi apiInstance = new BuyersApi(defaultClient);
    String xFactoryId = "xFactoryId_example"; // String | Factory UUID selected for the request scope
    try {
      apiInstance.buyersControllerFindAll(xFactoryId);
    } catch (ApiException e) {
      System.err.println("Exception when calling BuyersApi#buyersControllerFindAll");
      System.err.println("Status code: " + e.getCode());
      System.err.println("Reason: " + e.getResponseBody());
      System.err.println("Response headers: " + e.getResponseHeaders());
      e.printStackTrace();
    }
  }
}
```

### Parameters

| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **xFactoryId** | **String**| Factory UUID selected for the request scope | |

### Return type

null (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** |  |  -  |

<a id="buyersControllerRemove"></a>
# **buyersControllerRemove**
> buyersControllerRemove(xFactoryId, id)

Delete a buyer from the selected factory

### Example
```java
// Import classes:
import org.openapitools.client.ApiClient;
import org.openapitools.client.ApiException;
import org.openapitools.client.Configuration;
import org.openapitools.client.models.*;
import org.openapitools.client.api.BuyersApi;

public class Example {
  public static void main(String[] args) {
    ApiClient defaultClient = Configuration.getDefaultApiClient();
    defaultClient.setBasePath("http://localhost");

    BuyersApi apiInstance = new BuyersApi(defaultClient);
    String xFactoryId = "xFactoryId_example"; // String | Factory UUID selected for the request scope
    String id = "id_example"; // String | 
    try {
      apiInstance.buyersControllerRemove(xFactoryId, id);
    } catch (ApiException e) {
      System.err.println("Exception when calling BuyersApi#buyersControllerRemove");
      System.err.println("Status code: " + e.getCode());
      System.err.println("Reason: " + e.getResponseBody());
      System.err.println("Response headers: " + e.getResponseHeaders());
      e.printStackTrace();
    }
  }
}
```

### Parameters

| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **xFactoryId** | **String**| Factory UUID selected for the request scope | |
| **id** | **String**|  | |

### Return type

null (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** |  |  -  |

<a id="buyersControllerUpdate"></a>
# **buyersControllerUpdate**
> buyersControllerUpdate(xFactoryId, id, updateBuyerDto)

Update a buyer in the selected factory

### Example
```java
// Import classes:
import org.openapitools.client.ApiClient;
import org.openapitools.client.ApiException;
import org.openapitools.client.Configuration;
import org.openapitools.client.models.*;
import org.openapitools.client.api.BuyersApi;

public class Example {
  public static void main(String[] args) {
    ApiClient defaultClient = Configuration.getDefaultApiClient();
    defaultClient.setBasePath("http://localhost");

    BuyersApi apiInstance = new BuyersApi(defaultClient);
    String xFactoryId = "xFactoryId_example"; // String | Factory UUID selected for the request scope
    String id = "id_example"; // String | 
    UpdateBuyerDto updateBuyerDto = new UpdateBuyerDto(); // UpdateBuyerDto | 
    try {
      apiInstance.buyersControllerUpdate(xFactoryId, id, updateBuyerDto);
    } catch (ApiException e) {
      System.err.println("Exception when calling BuyersApi#buyersControllerUpdate");
      System.err.println("Status code: " + e.getCode());
      System.err.println("Reason: " + e.getResponseBody());
      System.err.println("Response headers: " + e.getResponseHeaders());
      e.printStackTrace();
    }
  }
}
```

### Parameters

| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **xFactoryId** | **String**| Factory UUID selected for the request scope | |
| **id** | **String**|  | |
| **updateBuyerDto** | [**UpdateBuyerDto**](UpdateBuyerDto.md)|  | |

### Return type

null (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** |  |  -  |

