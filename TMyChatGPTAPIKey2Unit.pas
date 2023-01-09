unit TMyChatGPTAPIKey2Unit;

interface

function GetOpenApiKey: string;

implementation
uses
  System.SysUtils;
function GetOpenApiKey: string;
begin
  GetOpenApiKey := GetEnvironmentVariable('OPENAI_API_KEY')
end;
end.
