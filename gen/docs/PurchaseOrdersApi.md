# PurchaseOrdersApi

All URIs are relative to *http://localhost*

| Method | HTTP request | Description |
|------------- | ------------- | -------------|
| [**purchaseOrdersControllerAddItem**](PurchaseOrdersApi.md#purchaseOrdersControllerAddItem) | **POST** /api/pos/{id}/items | Add an item to a draft purchase order |
| [**purchaseOrdersControllerConfirm**](PurchaseOrdersApi.md#purchaseOrdersControllerConfirm) | **POST** /api/pos/{id}/confirm | Confirm a draft purchase order |
| [**purchaseOrdersControllerCreate**](PurchaseOrdersApi.md#purchaseOrdersControllerCreate) | **POST** /api/pos | Create a purchase order header |
| [**purchaseOrdersControllerFindAll**](PurchaseOrdersApi.md#purchaseOrdersControllerFindAll) | **GET** /api/pos | List purchase orders for the selected factory |
| [**purchaseOrdersControllerFindOne**](PurchaseOrdersApi.md#purchaseOrdersControllerFindOne) | **GET** /api/pos/{id} | Get purchase order detail with items |
| [**purchaseOrdersControllerGetMaterialRequirement**](PurchaseOrdersApi.md#purchaseOrdersControllerGetMaterialRequirement) | **GET** /api/pos/{id}/material-requirement | Compute material requirements from PO item quantities and style BOMs |
| [**purchaseOrdersControllerUpdateStatus**](PurchaseOrdersApi.md#purchaseOrdersControllerUpdateStatus) | **POST** /api/pos/{id}/status | Update purchase order status; non-admin users can only move one step forward |


<a id="purchaseOrdersControllerAddItem"></a>
# **purchaseOrdersControllerAddItem**
> purchaseOrdersControllerAddItem(xFactoryId, id, addPoItemDto)

Add an item to a draft purchase order

### Example
```java
// Import classes:
import org.openapitools.client.ApiClient;
import org.openapitools.client.ApiException;
import org.openapitools.client.Configuration;
import org.openapitools.client.models.*;
import org.openapitools.client.api.PurchaseOrdersApi;

public class Example {
  public static void main(String[] args) {
    ApiClient defaultClient = Configuration.getDefaultApiClient();
    defaultClient.setBasePath("http://localhost");

    PurchaseOrdersApi apiInstance = new PurchaseOrdersApi(defaultClient);
    String xFactoryId = "xFactoryId_example"; // String | Factory UUID selected for the request scope
    String id = "id_example"; // String | 
    AddPoItemDto addPoItemDto = new AddPoItemDto(); // AddPoItemDto | 
    try {
      apiInstance.purchaseOrdersControllerAddItem(xFactoryId, id, addPoItemDto);
    } catch (ApiException e) {
      System.err.println("Exception when calling PurchaseOrdersApi#purchaseOrdersControllerAddItem");
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
| **addPoItemDto** | [**AddPoItemDto**](AddPoItemDto.md)|  | |

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

<a id="purchaseOrdersControllerConfirm"></a>
# **purchaseOrdersControllerConfirm**
> purchaseOrdersControllerConfirm(xFactoryId, id)

Confirm a draft purchase order

### Example
```java
// Import classes:
import org.openapitools.client.ApiClient;
import org.openapitools.client.ApiException;
import org.openapitools.client.Configuration;
import org.openapitools.client.models.*;
import org.openapitools.client.api.PurchaseOrdersApi;

public class Example {
  public static void main(String[] args) {
    ApiClient defaultClient = Configuration.getDefaultApiClient();
    defaultClient.setBasePath("http://localhost");

    PurchaseOrdersApi apiInstance = new PurchaseOrdersApi(defaultClient);
    String xFactoryId = "xFactoryId_example"; // String | Factory UUID selected for the request scope
    String id = "id_example"; // String | 
    try {
      apiInstance.purchaseOrdersControllerConfirm(xFactoryId, id);
    } catch (ApiException e) {
      System.err.println("Exception when calling PurchaseOrdersApi#purchaseOrdersControllerConfirm");
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
| **201** |  |  -  |

<a id="purchaseOrdersControllerCreate"></a>
# **purchaseOrdersControllerCreate**
> purchaseOrdersControllerCreate(xFactoryId, createPurchaseOrderDto)

Create a purchase order header

### Example
```java
// Import classes:
import org.openapitools.client.ApiClient;
import org.openapitools.client.ApiException;
import org.openapitools.client.Configuration;
import org.openapitools.client.models.*;
import org.openapitools.client.api.PurchaseOrdersApi;

public class Example {
  public static void main(String[] args) {
    ApiClient defaultClient = Configuration.getDefaultApiClient();
    defaultClient.setBasePath("http://localhost");

    PurchaseOrdersApi apiInstance = new PurchaseOrdersApi(defaultClient);
    String xFactoryId = "xFactoryId_example"; // String | Factory UUID selected for the request scope
    CreatePurchaseOrderDto createPurchaseOrderDto = new CreatePurchaseOrderDto(); // CreatePurchaseOrderDto | 
    try {
      apiInstance.purchaseOrdersControllerCreate(xFactoryId, createPurchaseOrderDto);
    } catch (ApiException e) {
      System.err.println("Exception when calling PurchaseOrdersApi#purchaseOrdersControllerCreate");
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
| **createPurchaseOrderDto** | [**CreatePurchaseOrderDto**](CreatePurchaseOrderDto.md)|  | |

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

<a id="purchaseOrdersControllerFindAll"></a>
# **purchaseOrdersControllerFindAll**
> purchaseOrdersControllerFindAll(xFactoryId)

List purchase orders for the selected factory

### Example
```java
// Import classes:
import org.openapitools.client.ApiClient;
import org.openapitools.client.ApiException;
import org.openapitools.client.Configuration;
import org.openapitools.client.models.*;
import org.openapitools.client.api.PurchaseOrdersApi;

public class Example {
  public static void main(String[] args) {
    ApiClient defaultClient = Configuration.getDefaultApiClient();
    defaultClient.setBasePath("http://localhost");

    PurchaseOrdersApi apiInstance = new PurchaseOrdersApi(defaultClient);
    String xFactoryId = "xFactoryId_example"; // String | Factory UUID selected for the request scope
    try {
      apiInstance.purchaseOrdersControllerFindAll(xFactoryId);
    } catch (ApiException e) {
      System.err.println("Exception when calling PurchaseOrdersApi#purchaseOrdersControllerFindAll");
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

<a id="purchaseOrdersControllerFindOne"></a>
# **purchaseOrdersControllerFindOne**
> purchaseOrdersControllerFindOne(xFactoryId, id)

Get purchase order detail with items

### Example
```java
// Import classes:
import org.openapitools.client.ApiClient;
import org.openapitools.client.ApiException;
import org.openapitools.client.Configuration;
import org.openapitools.client.models.*;
import org.openapitools.client.api.PurchaseOrdersApi;

public class Example {
  public static void main(String[] args) {
    ApiClient defaultClient = Configuration.getDefaultApiClient();
    defaultClient.setBasePath("http://localhost");

    PurchaseOrdersApi apiInstance = new PurchaseOrdersApi(defaultClient);
    String xFactoryId = "xFactoryId_example"; // String | Factory UUID selected for the request scope
    String id = "id_example"; // String | 
    try {
      apiInstance.purchaseOrdersControllerFindOne(xFactoryId, id);
    } catch (ApiException e) {
      System.err.println("Exception when calling PurchaseOrdersApi#purchaseOrdersControllerFindOne");
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

<a id="purchaseOrdersControllerGetMaterialRequirement"></a>
# **purchaseOrdersControllerGetMaterialRequirement**
> purchaseOrdersControllerGetMaterialRequirement(xFactoryId, id)

Compute material requirements from PO item quantities and style BOMs

### Example
```java
// Import classes:
import org.openapitools.client.ApiClient;
import org.openapitools.client.ApiException;
import org.openapitools.client.Configuration;
import org.openapitools.client.models.*;
import org.openapitools.client.api.PurchaseOrdersApi;

public class Example {
  public static void main(String[] args) {
    ApiClient defaultClient = Configuration.getDefaultApiClient();
    defaultClient.setBasePath("http://localhost");

    PurchaseOrdersApi apiInstance = new PurchaseOrdersApi(defaultClient);
    String xFactoryId = "xFactoryId_example"; // String | Factory UUID selected for the request scope
    String id = "id_example"; // String | 
    try {
      apiInstance.purchaseOrdersControllerGetMaterialRequirement(xFactoryId, id);
    } catch (ApiException e) {
      System.err.println("Exception when calling PurchaseOrdersApi#purchaseOrdersControllerGetMaterialRequirement");
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

<a id="purchaseOrdersControllerUpdateStatus"></a>
# **purchaseOrdersControllerUpdateStatus**
> purchaseOrdersControllerUpdateStatus(xFactoryId, id, updatePoStatusDto)

Update purchase order status; non-admin users can only move one step forward

### Example
```java
// Import classes:
import org.openapitools.client.ApiClient;
import org.openapitools.client.ApiException;
import org.openapitools.client.Configuration;
import org.openapitools.client.models.*;
import org.openapitools.client.api.PurchaseOrdersApi;

public class Example {
  public static void main(String[] args) {
    ApiClient defaultClient = Configuration.getDefaultApiClient();
    defaultClient.setBasePath("http://localhost");

    PurchaseOrdersApi apiInstance = new PurchaseOrdersApi(defaultClient);
    String xFactoryId = "xFactoryId_example"; // String | Factory UUID selected for the request scope
    String id = "id_example"; // String | 
    UpdatePoStatusDto updatePoStatusDto = new UpdatePoStatusDto(); // UpdatePoStatusDto | 
    try {
      apiInstance.purchaseOrdersControllerUpdateStatus(xFactoryId, id, updatePoStatusDto);
    } catch (ApiException e) {
      System.err.println("Exception when calling PurchaseOrdersApi#purchaseOrdersControllerUpdateStatus");
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
| **updatePoStatusDto** | [**UpdatePoStatusDto**](UpdatePoStatusDto.md)|  | |

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

