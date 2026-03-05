# SewingApi

All URIs are relative to *http://localhost*

| Method | HTTP request | Description |
|------------- | ------------- | -------------|
| [**sewingControllerCreateHourlyOutput**](SewingApi.md#sewingControllerCreateHourlyOutput) | **POST** /api/sewing/hourly-output | Create an hourly sewing output entry |
| [**sewingControllerGetLineStatus**](SewingApi.md#sewingControllerGetLineStatus) | **GET** /api/sewing/line-status | Get line status snapshot for a given date |


<a id="sewingControllerCreateHourlyOutput"></a>
# **sewingControllerCreateHourlyOutput**
> sewingControllerCreateHourlyOutput(xFactoryId, createHourlyOutputDto)

Create an hourly sewing output entry

### Example
```java
// Import classes:
import org.openapitools.client.ApiClient;
import org.openapitools.client.ApiException;
import org.openapitools.client.Configuration;
import org.openapitools.client.models.*;
import org.openapitools.client.api.SewingApi;

public class Example {
  public static void main(String[] args) {
    ApiClient defaultClient = Configuration.getDefaultApiClient();
    defaultClient.setBasePath("http://localhost");

    SewingApi apiInstance = new SewingApi(defaultClient);
    String xFactoryId = "xFactoryId_example"; // String | Factory UUID selected for the request scope
    CreateHourlyOutputDto createHourlyOutputDto = new CreateHourlyOutputDto(); // CreateHourlyOutputDto | 
    try {
      apiInstance.sewingControllerCreateHourlyOutput(xFactoryId, createHourlyOutputDto);
    } catch (ApiException e) {
      System.err.println("Exception when calling SewingApi#sewingControllerCreateHourlyOutput");
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
| **createHourlyOutputDto** | [**CreateHourlyOutputDto**](CreateHourlyOutputDto.md)|  | |

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

<a id="sewingControllerGetLineStatus"></a>
# **sewingControllerGetLineStatus**
> sewingControllerGetLineStatus(xFactoryId, date)

Get line status snapshot for a given date

### Example
```java
// Import classes:
import org.openapitools.client.ApiClient;
import org.openapitools.client.ApiException;
import org.openapitools.client.Configuration;
import org.openapitools.client.models.*;
import org.openapitools.client.api.SewingApi;

public class Example {
  public static void main(String[] args) {
    ApiClient defaultClient = Configuration.getDefaultApiClient();
    defaultClient.setBasePath("http://localhost");

    SewingApi apiInstance = new SewingApi(defaultClient);
    String xFactoryId = "xFactoryId_example"; // String | Factory UUID selected for the request scope
    String date = "2026-04-02"; // String | 
    try {
      apiInstance.sewingControllerGetLineStatus(xFactoryId, date);
    } catch (ApiException e) {
      System.err.println("Exception when calling SewingApi#sewingControllerGetLineStatus");
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
| **date** | **String**|  | |

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

