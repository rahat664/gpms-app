# StylesApi

All URIs are relative to *http://localhost*

| Method | HTTP request | Description |
|------------- | ------------- | -------------|
| [**stylesControllerCreate**](StylesApi.md#stylesControllerCreate) | **POST** /api/styles | Create a style in the selected factory |
| [**stylesControllerFindAll**](StylesApi.md#stylesControllerFindAll) | **GET** /api/styles | List styles for the selected factory |
| [**stylesControllerGetBom**](StylesApi.md#stylesControllerGetBom) | **GET** /api/styles/{id}/bom | Get the BOM for a style |
| [**stylesControllerRemove**](StylesApi.md#stylesControllerRemove) | **DELETE** /api/styles/{id} | Delete a style from the selected factory |
| [**stylesControllerUpdate**](StylesApi.md#stylesControllerUpdate) | **PUT** /api/styles/{id} | Update a style in the selected factory |
| [**stylesControllerUpsertBom**](StylesApi.md#stylesControllerUpsertBom) | **POST** /api/styles/{id}/bom | Create or replace the BOM for a style |


<a id="stylesControllerCreate"></a>
# **stylesControllerCreate**
> stylesControllerCreate(xFactoryId, createStyleDto)

Create a style in the selected factory

### Example
```java
// Import classes:
import org.openapitools.client.ApiClient;
import org.openapitools.client.ApiException;
import org.openapitools.client.Configuration;
import org.openapitools.client.models.*;
import org.openapitools.client.api.StylesApi;

public class Example {
  public static void main(String[] args) {
    ApiClient defaultClient = Configuration.getDefaultApiClient();
    defaultClient.setBasePath("http://localhost");

    StylesApi apiInstance = new StylesApi(defaultClient);
    String xFactoryId = "xFactoryId_example"; // String | Factory UUID selected for the request scope
    CreateStyleDto createStyleDto = new CreateStyleDto(); // CreateStyleDto | 
    try {
      apiInstance.stylesControllerCreate(xFactoryId, createStyleDto);
    } catch (ApiException e) {
      System.err.println("Exception when calling StylesApi#stylesControllerCreate");
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
| **createStyleDto** | [**CreateStyleDto**](CreateStyleDto.md)|  | |

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

<a id="stylesControllerFindAll"></a>
# **stylesControllerFindAll**
> stylesControllerFindAll(xFactoryId)

List styles for the selected factory

### Example
```java
// Import classes:
import org.openapitools.client.ApiClient;
import org.openapitools.client.ApiException;
import org.openapitools.client.Configuration;
import org.openapitools.client.models.*;
import org.openapitools.client.api.StylesApi;

public class Example {
  public static void main(String[] args) {
    ApiClient defaultClient = Configuration.getDefaultApiClient();
    defaultClient.setBasePath("http://localhost");

    StylesApi apiInstance = new StylesApi(defaultClient);
    String xFactoryId = "xFactoryId_example"; // String | Factory UUID selected for the request scope
    try {
      apiInstance.stylesControllerFindAll(xFactoryId);
    } catch (ApiException e) {
      System.err.println("Exception when calling StylesApi#stylesControllerFindAll");
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

<a id="stylesControllerGetBom"></a>
# **stylesControllerGetBom**
> stylesControllerGetBom(xFactoryId, id)

Get the BOM for a style

### Example
```java
// Import classes:
import org.openapitools.client.ApiClient;
import org.openapitools.client.ApiException;
import org.openapitools.client.Configuration;
import org.openapitools.client.models.*;
import org.openapitools.client.api.StylesApi;

public class Example {
  public static void main(String[] args) {
    ApiClient defaultClient = Configuration.getDefaultApiClient();
    defaultClient.setBasePath("http://localhost");

    StylesApi apiInstance = new StylesApi(defaultClient);
    String xFactoryId = "xFactoryId_example"; // String | Factory UUID selected for the request scope
    String id = "id_example"; // String | 
    try {
      apiInstance.stylesControllerGetBom(xFactoryId, id);
    } catch (ApiException e) {
      System.err.println("Exception when calling StylesApi#stylesControllerGetBom");
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

<a id="stylesControllerRemove"></a>
# **stylesControllerRemove**
> stylesControllerRemove(xFactoryId, id)

Delete a style from the selected factory

### Example
```java
// Import classes:
import org.openapitools.client.ApiClient;
import org.openapitools.client.ApiException;
import org.openapitools.client.Configuration;
import org.openapitools.client.models.*;
import org.openapitools.client.api.StylesApi;

public class Example {
  public static void main(String[] args) {
    ApiClient defaultClient = Configuration.getDefaultApiClient();
    defaultClient.setBasePath("http://localhost");

    StylesApi apiInstance = new StylesApi(defaultClient);
    String xFactoryId = "xFactoryId_example"; // String | Factory UUID selected for the request scope
    String id = "id_example"; // String | 
    try {
      apiInstance.stylesControllerRemove(xFactoryId, id);
    } catch (ApiException e) {
      System.err.println("Exception when calling StylesApi#stylesControllerRemove");
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

<a id="stylesControllerUpdate"></a>
# **stylesControllerUpdate**
> stylesControllerUpdate(xFactoryId, id, updateStyleDto)

Update a style in the selected factory

### Example
```java
// Import classes:
import org.openapitools.client.ApiClient;
import org.openapitools.client.ApiException;
import org.openapitools.client.Configuration;
import org.openapitools.client.models.*;
import org.openapitools.client.api.StylesApi;

public class Example {
  public static void main(String[] args) {
    ApiClient defaultClient = Configuration.getDefaultApiClient();
    defaultClient.setBasePath("http://localhost");

    StylesApi apiInstance = new StylesApi(defaultClient);
    String xFactoryId = "xFactoryId_example"; // String | Factory UUID selected for the request scope
    String id = "id_example"; // String | 
    UpdateStyleDto updateStyleDto = new UpdateStyleDto(); // UpdateStyleDto | 
    try {
      apiInstance.stylesControllerUpdate(xFactoryId, id, updateStyleDto);
    } catch (ApiException e) {
      System.err.println("Exception when calling StylesApi#stylesControllerUpdate");
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
| **updateStyleDto** | [**UpdateStyleDto**](UpdateStyleDto.md)|  | |

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

<a id="stylesControllerUpsertBom"></a>
# **stylesControllerUpsertBom**
> stylesControllerUpsertBom(xFactoryId, id, upsertBomDto)

Create or replace the BOM for a style

### Example
```java
// Import classes:
import org.openapitools.client.ApiClient;
import org.openapitools.client.ApiException;
import org.openapitools.client.Configuration;
import org.openapitools.client.models.*;
import org.openapitools.client.api.StylesApi;

public class Example {
  public static void main(String[] args) {
    ApiClient defaultClient = Configuration.getDefaultApiClient();
    defaultClient.setBasePath("http://localhost");

    StylesApi apiInstance = new StylesApi(defaultClient);
    String xFactoryId = "xFactoryId_example"; // String | Factory UUID selected for the request scope
    String id = "id_example"; // String | 
    UpsertBomDto upsertBomDto = new UpsertBomDto(); // UpsertBomDto | 
    try {
      apiInstance.stylesControllerUpsertBom(xFactoryId, id, upsertBomDto);
    } catch (ApiException e) {
      System.err.println("Exception when calling StylesApi#stylesControllerUpsertBom");
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
| **upsertBomDto** | [**UpsertBomDto**](UpsertBomDto.md)|  | |

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

