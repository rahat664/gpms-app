# QcApi

All URIs are relative to *http://localhost*

| Method | HTTP request | Description |
|------------- | ------------- | -------------|
| [**qcControllerGetSummary**](QcApi.md#qcControllerGetSummary) | **GET** /api/qc/summary | Get QC summary for a specific date |
| [**qcControllerInspect**](QcApi.md#qcControllerInspect) | **POST** /api/qc/inspect | Create a QC inspection for a bundle |


<a id="qcControllerGetSummary"></a>
# **qcControllerGetSummary**
> qcControllerGetSummary(xFactoryId, date)

Get QC summary for a specific date

### Example
```java
// Import classes:
import org.openapitools.client.ApiClient;
import org.openapitools.client.ApiException;
import org.openapitools.client.Configuration;
import org.openapitools.client.models.*;
import org.openapitools.client.api.QcApi;

public class Example {
  public static void main(String[] args) {
    ApiClient defaultClient = Configuration.getDefaultApiClient();
    defaultClient.setBasePath("http://localhost");

    QcApi apiInstance = new QcApi(defaultClient);
    String xFactoryId = "xFactoryId_example"; // String | Factory UUID selected for the request scope
    String date = "2026-04-02"; // String | 
    try {
      apiInstance.qcControllerGetSummary(xFactoryId, date);
    } catch (ApiException e) {
      System.err.println("Exception when calling QcApi#qcControllerGetSummary");
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

<a id="qcControllerInspect"></a>
# **qcControllerInspect**
> qcControllerInspect(xFactoryId, createQcInspectionDto)

Create a QC inspection for a bundle

### Example
```java
// Import classes:
import org.openapitools.client.ApiClient;
import org.openapitools.client.ApiException;
import org.openapitools.client.Configuration;
import org.openapitools.client.models.*;
import org.openapitools.client.api.QcApi;

public class Example {
  public static void main(String[] args) {
    ApiClient defaultClient = Configuration.getDefaultApiClient();
    defaultClient.setBasePath("http://localhost");

    QcApi apiInstance = new QcApi(defaultClient);
    String xFactoryId = "xFactoryId_example"; // String | Factory UUID selected for the request scope
    CreateQcInspectionDto createQcInspectionDto = new CreateQcInspectionDto(); // CreateQcInspectionDto | 
    try {
      apiInstance.qcControllerInspect(xFactoryId, createQcInspectionDto);
    } catch (ApiException e) {
      System.err.println("Exception when calling QcApi#qcControllerInspect");
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
| **createQcInspectionDto** | [**CreateQcInspectionDto**](CreateQcInspectionDto.md)|  | |

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

