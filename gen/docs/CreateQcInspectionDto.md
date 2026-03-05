

# CreateQcInspectionDto


## Properties

| Name | Type | Description | Notes |
|------------ | ------------- | ------------- | -------------|
|**bundleId** | **String** |  |  |
|**type** | [**TypeEnum**](#TypeEnum) |  |  |
|**pass** | **Boolean** |  |  |
|**notes** | **String** |  |  [optional] |
|**defects** | [**List&lt;QcDefectDto&gt;**](QcDefectDto.md) |  |  [optional] |



## Enum: TypeEnum

| Name | Value |
|---- | -----|
| INLINE | &quot;INLINE&quot; |
| ENDLINE | &quot;ENDLINE&quot; |
| FINAL | &quot;FINAL&quot; |



