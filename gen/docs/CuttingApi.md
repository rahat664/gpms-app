# CuttingApi

All URIs are relative to *http://localhost*

| Method | HTTP request | Description |
|------------- | ------------- | -------------|
| [**cuttingControllerCreateBatch**](CuttingApi.md#cuttingControllerCreateBatch) | **POST** /api/cutting/batches | Create a cutting batch |
| [**cuttingControllerCreateBundles**](CuttingApi.md#cuttingControllerCreateBundles) | **POST** /api/cutting/batches/{id}/bundles | Create bundles for a cutting batch |
| [**cuttingControllerFindOne**](CuttingApi.md#cuttingControllerFindOne) | **GET** /api/cutting/batches/{id} | Get a cutting batch with bundles |
| [**cuttingControllerListBundles**](CuttingApi.md#cuttingControllerListBundles) | **GET** /api/cutting/bundles | List bundles in the selected factory |


<a id="cuttingControllerCreateBatch"></a>
# **cuttingControllerCreateBatch**
> cuttingControllerCreateBatch(xFactoryId, createCuttingBatchDto)

Create a cutting batch

### Example
```java
// Import classes:
import org.openapitools.client.ApiClient;
import org.openapitools.client.ApiException;
import org.openapitools.client.Configuration;
import org.openapitools.client.models.*;
import org.openapitools.client.api.CuttingApi;

public class Example {
  public static void main(String[] args) {
    ApiClient defaultClient = Configuration.getDefaultApiClient();
    defaultClient.setBasePath("http://localhost");

    CuttingApi apiInstance = new CuttingApi(defaultClient);
    String xFactoryId = "xFactoryId_example"; // String | Factory UUID selected for the request scope
    CreateCuttingBatchDto createCuttingBatchDto = new CreateCuttingBatchDto(); // CreateCuttingBatchDto | 
    try {
      apiInstance.cuttingControllerCreateBatch(xFactoryId, createCuttingBatchDto);
    } catch (ApiException e) {
      System.err.println("Exception when calling CuttingApi#cuttingControllerCreateBatch");
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
| **createCuttingBatchDto** | [**CreateCuttingBatchDto**](CreateCuttingBatchDto.md)|  | |

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

<a id="cuttingControllerCreateBundles"></a>
# **cuttingControllerCreateBundles**
> cuttingControllerCreateBundles(xFactoryId, id, createBundlesDto)

Create bundles for a cutting batch

### Example
```java
// Import classes:
import org.openapitools.client.ApiClient;
import org.openapitools.client.ApiException;
import org.openapitools.client.Configuration;
import org.openapitools.client.models.*;
import org.openapitools.client.api.CuttingApi;

public class Example {
  public static void main(String[] args) {
    ApiClient defaultClient = Configuration.getDefaultApiClient();
    defaultClient.setBasePath("http://localhost");

    CuttingApi apiInstance = new CuttingApi(defaultClient);
    String xFactoryId = "xFactoryId_example"; // String | Factory UUID selected for the request scope
    String id = "id_example"; // String | 
    CreateBundlesDto createBundlesDto = new CreateBundlesDto(); // CreateBundlesDto | 
    try {
      apiInstance.cuttingControllerCreateBundles(xFactoryId, id, createBundlesDto);
    } catch (ApiException e) {
      System.err.println("Exception when calling CuttingApi#cuttingControllerCreateBundles");
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
| **createBundlesDto** | [**CreateBundlesDto**](CreateBundlesDto.md)|  | |

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

<a id="cuttingControllerFindOne"></a>
# **cuttingControllerFindOne**
> cuttingControllerFindOne(xFactoryId, id)

Get a cutting batch with bundles

### Example
```java
// Import classes:
import org.openapitools.client.ApiClient;
import org.openapitools.client.ApiException;
import org.openapitools.client.Configuration;
import org.openapitools.client.models.*;
import org.openapitools.client.api.CuttingApi;

public class Example {
  public static void main(String[] args) {
    ApiClient defaultClient = Configuration.getDefaultApiClient();
    defaultClient.setBasePath("http://localhost");

    CuttingApi apiInstance = new CuttingApi(defaultClient);
    String xFactoryId = "xFactoryId_example"; // String | Factory UUID selected for the request scope
    String id = "id_example"; // String | 
    try {
      apiInstance.cuttingControllerFindOne(xFactoryId, id);
    } catch (ApiException e) {
      System.err.println("Exception when calling CuttingApi#cuttingControllerFindOne");
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

<a id="cuttingControllerListBundles"></a>
# **cuttingControllerListBundles**
> cuttingControllerListBundles(xFactoryId, q)

List bundles in the selected factory

### Example
```java
// Import classes:
import org.openapitools.client.ApiClient;
import org.openapitools.client.ApiException;
import org.openapitools.client.Configuration;
import org.openapitools.client.models.*;
import org.openapitools.client.api.CuttingApi;

public class Example {
  public static void main(String[] args) {
    ApiClient defaultClient = Configuration.getDefaultApiClient();
    defaultClient.setBasePath("http://localhost");

    CuttingApi apiInstance = new CuttingApi(defaultClient);
    String xFactoryId = "xFactoryId_example"; // String | Factory UUID selected for the request scope
    String q = "q_example"; // String | 
    try {
      apiInstance.cuttingControllerListBundles(xFactoryId, q);
    } catch (ApiException e) {
      System.err.println("Exception when calling CuttingApi#cuttingControllerListBundles");
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
| **q** | **String**|  | |

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

