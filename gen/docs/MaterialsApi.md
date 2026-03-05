# MaterialsApi

All URIs are relative to *http://localhost*

| Method | HTTP request | Description |
|------------- | ------------- | -------------|
| [**materialsControllerCreate**](MaterialsApi.md#materialsControllerCreate) | **POST** /api/materials | Create a material in the selected factory |
| [**materialsControllerFindAll**](MaterialsApi.md#materialsControllerFindAll) | **GET** /api/materials | List materials for the selected factory |


<a id="materialsControllerCreate"></a>
# **materialsControllerCreate**
> materialsControllerCreate(xFactoryId, createMaterialDto)

Create a material in the selected factory

### Example
```java
// Import classes:
import org.openapitools.client.ApiClient;
import org.openapitools.client.ApiException;
import org.openapitools.client.Configuration;
import org.openapitools.client.models.*;
import org.openapitools.client.api.MaterialsApi;

public class Example {
  public static void main(String[] args) {
    ApiClient defaultClient = Configuration.getDefaultApiClient();
    defaultClient.setBasePath("http://localhost");

    MaterialsApi apiInstance = new MaterialsApi(defaultClient);
    String xFactoryId = "xFactoryId_example"; // String | Factory UUID selected for the request scope
    CreateMaterialDto createMaterialDto = new CreateMaterialDto(); // CreateMaterialDto | 
    try {
      apiInstance.materialsControllerCreate(xFactoryId, createMaterialDto);
    } catch (ApiException e) {
      System.err.println("Exception when calling MaterialsApi#materialsControllerCreate");
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
| **createMaterialDto** | [**CreateMaterialDto**](CreateMaterialDto.md)|  | |

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

<a id="materialsControllerFindAll"></a>
# **materialsControllerFindAll**
> materialsControllerFindAll(xFactoryId)

List materials for the selected factory

### Example
```java
// Import classes:
import org.openapitools.client.ApiClient;
import org.openapitools.client.ApiException;
import org.openapitools.client.Configuration;
import org.openapitools.client.models.*;
import org.openapitools.client.api.MaterialsApi;

public class Example {
  public static void main(String[] args) {
    ApiClient defaultClient = Configuration.getDefaultApiClient();
    defaultClient.setBasePath("http://localhost");

    MaterialsApi apiInstance = new MaterialsApi(defaultClient);
    String xFactoryId = "xFactoryId_example"; // String | Factory UUID selected for the request scope
    try {
      apiInstance.materialsControllerFindAll(xFactoryId);
    } catch (ApiException e) {
      System.err.println("Exception when calling MaterialsApi#materialsControllerFindAll");
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

