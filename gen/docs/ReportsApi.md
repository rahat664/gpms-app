# ReportsApi

All URIs are relative to *http://localhost*

| Method | HTTP request | Description |
|------------- | ------------- | -------------|
| [**reportsControllerGetPlanVsActual**](ReportsApi.md#reportsControllerGetPlanVsActual) | **GET** /api/reports/plan-vs-actual | Get target vs actual output by line for a given date |


<a id="reportsControllerGetPlanVsActual"></a>
# **reportsControllerGetPlanVsActual**
> reportsControllerGetPlanVsActual(xFactoryId, date)

Get target vs actual output by line for a given date

### Example
```java
// Import classes:
import org.openapitools.client.ApiClient;
import org.openapitools.client.ApiException;
import org.openapitools.client.Configuration;
import org.openapitools.client.models.*;
import org.openapitools.client.api.ReportsApi;

public class Example {
  public static void main(String[] args) {
    ApiClient defaultClient = Configuration.getDefaultApiClient();
    defaultClient.setBasePath("http://localhost");

    ReportsApi apiInstance = new ReportsApi(defaultClient);
    String xFactoryId = "xFactoryId_example"; // String | Factory UUID selected for the request scope
    String date = "2026-04-02"; // String | 
    try {
      apiInstance.reportsControllerGetPlanVsActual(xFactoryId, date);
    } catch (ApiException e) {
      System.err.println("Exception when calling ReportsApi#reportsControllerGetPlanVsActual");
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

