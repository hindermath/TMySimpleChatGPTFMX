unit TMySimpleChatGPTUnit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.TMSFNCTypes, FMX.TMSFNCUtils, FMX.TMSFNCGraphics, FMX.TMSFNCGraphicsTypes,
  FMX.Edit, FMX.TMSFNCEdit, FMX.TMSFNCCustomControl, FMX.TMSFNCWebBrowser,
  FMX.TMSFNCCustomWEBControl, FMX.TMSFNCWXHTMLMemo, FMX.Controls.Presentation,
  FMX.StdCtrls, FMX.TMSFNCButton, System.JSON, TMyChatGPTAPIKey2Unit,
  FMX.TMSFNCCloudBase, System.Generics.Collections, FMX.TMSFNCHTMLText,
  FMX.TMSFNCLabelEdit, FMX.TMSFNCCustomPicker, FMX.TMSFNCComboBox;

const
  OPENAIHOST = 'https://api.openai.com';
  OPENAIAPIVERV1 = '/v1/';

type
  TTMySimpleChatGPTForm = class(TForm)
    TMySimpleChatGPTButton: TTMSFNCButton;
    TMySimpleChatGPTMemo: TTMSFNCWXHTMLMemo;
    TMySimpleChatGPTEdit: TTMSFNCEdit;
    TMySimpleChatGPTComboBox: TTMSFNCComboBox;
    TMySimpleChatGPTLabelEdit: TTMSFNCLabelEdit;
    procedure TMySimpleChatGPTButtonClick(Sender: TObject);
    function TMyAskChatGPT(AQuestion: string): string;
    procedure TMySimpleChatGPTFormCreate(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  TMySimpleChatGPTForm: TTMySimpleChatGPTForm;

implementation

{$R *.fmx}
{$R *.Windows.fmx MSWINDOWS}
{$R *.Macintosh.fmx MACOS}

procedure TTMySimpleChatGPTForm.TMySimpleChatGPTButtonClick(Sender: TObject);
begin
  TMySimpleChatGPTMemo.HTML.Text := TMyAskChatGPT(TMySimpleChatGPTEdit.Text);
end;

procedure TTMySimpleChatGPTForm.TMySimpleChatGPTFormCreate(Sender: TObject);
var
  TMyCB :TTMSFNCCloudBase;
  TMyJsonValue: TJSONValue;
  TMyJsonArray: TJSONArray;
  TMyJsonItem: TJSONValue;

begin
    // Create an instance of TMS FNC Cloud Base class
    TMyCB := TTMSFNCCloudBase.Create;
    try
      // Use JSON for the REST API calls ans set API Key via authorization header
      TMyCb.Request.AddHeader('Authorization','Bearer ' + GetOpenApiKey);
      TMyCB.Request.Method := rmGET;
      TMyCB.Request.Host := OPENAIHOST;
      TMyCB.Request.Path := OPENAIAPIVERV1 + 'models';

      // Execute the HTTPS POST synchronously -> last parameter Async = false
      TMyCB.ExecuteRequest(nil, nil, False);

      // Process returned JSON when request was successful
      if TMyCB.RequestResult.Success then
      begin
        TMyJsonValue := TJSONObject.ParseJSONValue(TMyCB.RequestResult.ResultString);
        TMyJsonValue := TMyJsonValue.GetValue<TJSONValue>('data');
        if TMyJsonValue is TJSONArray then
        begin
          TMyJsonArray := TMyJsonValue as TJSONArray;
          for TMyJsonItem in TMyJsonArray do
            TMySimpleChatGPTComboBox.Items.Add(TMyJsonItem.GetValue<TJSONString>('id').ToString);
        end;
      end
      else
        raise Exception.Create('HTTP reponse code: ' + TMyCB.RequestResult.ResponseCode.ToString);
    finally
      TMyCB.Free;
    end;

end;

function TTMySimpleChatGPTForm.TMyAskChatGPT(AQuestion: string): string;
var
  TMyCB: TTMSFNCCloudBase;
  TMyPostData: string;
  TMyJsonValue: TJSONValue;
  TMyJsonArray: TJSONArray;
  TMyJsonString: TJSONString;

begin
  Result := '';

  TMyPostData := '{' +
    '"model": "text-davinci-003",'+
    '"prompt": "' + AQuestion + '",'+
    '"max_tokens": 2048,'+
    '"temperature": 0,'+
    '"echo": true' +
    '}';

    // Create an instance of TMS FNC Cloud Base class
    TMyCB := TTMSFNCCloudBase.Create;

    try
      // Use JSON for the REST API calls ans set API Key via authorization header
      TMyCb.Request.AddHeader('Authorization','Bearer ' + GetOpenApiKey);
      TMyCb.Request.AddHeader('Content-Type','application/json');

      // Select HTTPS POST method, set POST data and specify end point URL
      TMyCB.Request.Method := rmPOST;
      TMyCB.Request.PostData := TMyPostData;
      TMyCB.Request.Host := 'https://api.openai.com';
      TMyCB.Request.Path := OPENAIAPIVERV1 + 'completions';

      // Execute the HTTPS POST synchronously -> last parameter Async = false
      TMyCB.ExecuteRequest(nil, nil, False);

      // Process returned JSON when request was successful
      if TMyCB.RequestResult.Success then
      begin
        TMySimpleChatGPTEdit.Text := TMySimpleChatGPTEdit.Text.Empty;
        TMyJsonValue := TJSONObject.ParseJSONValue(TMyCB.RequestResult.ResultString);
        TMyJsonValue := TMyJsonValue.GetValue<TJSONValue>('choices');
        if TMyJsonValue is TJSONArray then
        begin
          TMyJsonArray := TMyJsonValue as TJSONArray;
          TMyJsonString := TMyJsonArray.Items[0].GetValue<TJSONString>('text');
          Result := TMyJsonString.Value;
        end
      end
      else
        raise Exception.Create('HTTP response code: ' + TMyCB.RequestResult.ResponseCode.ToString);
    finally
      TMyCB.Free;
    end;
end;

end.
