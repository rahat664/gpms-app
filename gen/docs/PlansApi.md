# PlansApi

All URIs are relative to *http://localhost*

| Method | HTTP request | Description |
|------------- | ------------- | -------------|
| [**plansControllerAssign**](PlansApi.md#plansControllerAssign) | **POST** /api/plans/{id}/assign | Assign a PO item to a line within a production plan |
| [**plansControllerCreate**](PlansApi.md#plansControllerCreate) | **POST** /api/plans | Create a production plan |
| [**plansControllerFindOne**](PlansApi.md#plansControllerFindOne) | **GET** /api/plans/{id} | Get production plan detail with plan lines and targets |


<a id="plansControllerAssign"></a>
# **plansControllerAssign**
> plansControllerAssign(xFactoryId, id, assignPlanLineDto)

Assign a PO item to a line within a production plan

### Example
```java
// Import classes:
import org.openapitools.client.ApiClient;
import org.openapitools.client.ApiException;
import org.openapitools.client.Configuration;
import org.openapitools.client.models.*;
import org.openapitools.client.api.PlansApi;

public class Example {
  public static void main(String[] args) {
    ApiClient defaultClient = Configuration.getDefaultApiClient();
    defaultClient.setBasePath("http://localhost");

    PlansApi apiInstance = new PlansApi(defaultClient);
    String xFactoryId = "xFactoryId_example"; // String | Factory UUID selected for the request scope
    String id = "id_example"; // String | 
    AssignPlanLineDto assignPlanLineDto = new AssignPlanLineDto(); // AssignPlanLineDto | 
    try {
      apiInstance.plansControllerAssign(xFactoryId, id, assignPlanLineDto);
    } catch (ApiException e) {
      System.err.println("Exception when calling PlansApi#plansControllerAssign");
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
| **assignPlanLineDto** | [**AssignPlanLineDto**](AssignPlanLineDto.md)|  | |

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

<a id="plansControllerCreate"></a>
# **plansControllerCreate**
> plansControllerCreate(xFactoryId, createPlanDto)

Create a production plan

### Example
```java
// Import classes:
import org.openapitools.client.ApiClient;
import org.openapitools.client.ApiException;
import org.openapitools.client.Configuration;
import org.openapitools.client.models.*;
import org.openapitools.client.api.PlansApi;

public class Example {
  public static void main(String[] args) {
    ApiClient defaultClient = Configuration.getDefaultApiClient();
    defaultClient.setBasePath("http://localhost");

    PlansApi apiInstance = new PlansApi(defaultClient);
    String xFactoryId = "xFactoryId_example"; // String | Factory UUID selected for the request scope
    CreatePlanDto createPlanDto = new CreatePlanDto(); // CreatePlanDto | 
    try {
      apiInstance.plansControllerCreate(xFactoryId, createPlanDto);
    } catch (ApiException e) {
      System.err.println("Exception when calling PlansApi#plansControllerCreate");
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
| **createPlanDto** | [**CreatePlanDto**](CreatePlanDto.md)|  | |

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

<a id="plansControllerFindOne"></a>
# **plansControllerFindOne**
> plansControllerFindOne(xFactoryId, id)

Get production plan detail with plan lines and targets

### Example
```java
// Import classes:
import org.openapitools.client.ApiClient;
import org.openapitools.client.ApiException;
import org.openapitools.client.Configuration;
import org.openapitools.client.models.*;
import org.openapitools.client.api.PlansApi;

public class Example {
  public static void main(String[] args) {
    ApiClient defaultClient = Configuration.getDefaultApiClient();
    defaultClient.setBasePath("http://localhost");

    PlansApi apiInstance = new PlansApi(defaultClient);
    String xFactoryId = "xFactoryId_example"; // String | Factory UUID selected for the request scope
    String id = "id_example"; // String | 
    try {
      apiInstance.plansControllerFindOne(xFactoryId, id);
    } catch (ApiException e) {
      System.err.println("Exception when calling PlansApi#plansControllerFindOne");
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

