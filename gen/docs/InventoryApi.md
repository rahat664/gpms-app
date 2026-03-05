# InventoryApi

All URIs are relative to *http://localhost*

| Method | HTTP request | Description |
|------------- | ------------- | -------------|
| [**inventoryControllerGetStock**](InventoryApi.md#inventoryControllerGetStock) | **GET** /api/inventory/stock | Get current stock by material from ledger transactions |
| [**inventoryControllerIssueToCutting**](InventoryApi.md#inventoryControllerIssueToCutting) | **POST** /api/inventory/issue-to-cutting | Issue inventory to cutting from the selected factory ledger |
| [**inventoryControllerReceive**](InventoryApi.md#inventoryControllerReceive) | **POST** /api/inventory/receive | Receive inventory into the selected factory ledger |


<a id="inventoryControllerGetStock"></a>
# **inventoryControllerGetStock**
> inventoryControllerGetStock(xFactoryId, materialId)

Get current stock by material from ledger transactions

### Example
```java
// Import classes:
import org.openapitools.client.ApiClient;
import org.openapitools.client.ApiException;
import org.openapitools.client.Configuration;
import org.openapitools.client.models.*;
import org.openapitools.client.api.InventoryApi;

public class Example {
  public static void main(String[] args) {
    ApiClient defaultClient = Configuration.getDefaultApiClient();
    defaultClient.setBasePath("http://localhost");

    InventoryApi apiInstance = new InventoryApi(defaultClient);
    String xFactoryId = "xFactoryId_example"; // String | Factory UUID selected for the request scope
    String materialId = "9a3a44d1-0b0a-4fe9-a6ad-66db595d9b82"; // String | 
    try {
      apiInstance.inventoryControllerGetStock(xFactoryId, materialId);
    } catch (ApiException e) {
      System.err.println("Exception when calling InventoryApi#inventoryControllerGetStock");
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
| **materialId** | **String**|  | [optional] |

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

<a id="inventoryControllerIssueToCutting"></a>
# **inventoryControllerIssueToCutting**
> inventoryControllerIssueToCutting(xFactoryId, issueToCuttingDto)

Issue inventory to cutting from the selected factory ledger

### Example
```java
// Import classes:
import org.openapitools.client.ApiClient;
import org.openapitools.client.ApiException;
import org.openapitools.client.Configuration;
import org.openapitools.client.models.*;
import org.openapitools.client.api.InventoryApi;

public class Example {
  public static void main(String[] args) {
    ApiClient defaultClient = Configuration.getDefaultApiClient();
    defaultClient.setBasePath("http://localhost");

    InventoryApi apiInstance = new InventoryApi(defaultClient);
    String xFactoryId = "xFactoryId_example"; // String | Factory UUID selected for the request scope
    IssueToCuttingDto issueToCuttingDto = new IssueToCuttingDto(); // IssueToCuttingDto | 
    try {
      apiInstance.inventoryControllerIssueToCutting(xFactoryId, issueToCuttingDto);
    } catch (ApiException e) {
      System.err.println("Exception when calling InventoryApi#inventoryControllerIssueToCutting");
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
| **issueToCuttingDto** | [**IssueToCuttingDto**](IssueToCuttingDto.md)|  | |

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

<a id="inventoryControllerReceive"></a>
# **inventoryControllerReceive**
> inventoryControllerReceive(xFactoryId, receiveInventoryDto)

Receive inventory into the selected factory ledger

### Example
```java
// Import classes:
import org.openapitools.client.ApiClient;
import org.openapitools.client.ApiException;
import org.openapitools.client.Configuration;
import org.openapitools.client.models.*;
import org.openapitools.client.api.InventoryApi;

public class Example {
  public static void main(String[] args) {
    ApiClient defaultClient = Configuration.getDefaultApiClient();
    defaultClient.setBasePath("http://localhost");

    InventoryApi apiInstance = new InventoryApi(defaultClient);
    String xFactoryId = "xFactoryId_example"; // String | Factory UUID selected for the request scope
    ReceiveInventoryDto receiveInventoryDto = new ReceiveInventoryDto(); // ReceiveInventoryDto | 
    try {
      apiInstance.inventoryControllerReceive(xFactoryId, receiveInventoryDto);
    } catch (ApiException e) {
      System.err.println("Exception when calling InventoryApi#inventoryControllerReceive");
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
| **receiveInventoryDto** | [**ReceiveInventoryDto**](ReceiveInventoryDto.md)|  | |

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

