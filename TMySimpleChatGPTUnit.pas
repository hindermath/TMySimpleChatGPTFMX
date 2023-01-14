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
    function TMyAskChatGPT(AQuestion: string; AModel: String): string;
    procedure TMySimpleChatGPTFormCreate(Sender: TObject);
    procedure TMySimpleChatGPTComboBoxItemSelected(Sender: TObject;
      AText: string; AItemIndex: Integer);

  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
    TMySimpleChatGPTModel: string;
  end;

var
  TMySimpleChatGPTForm: TTMySimpleChatGPTForm;

  TMyCB :TTMSFNCCloudBase;
  TMyJsonValue: TJSONValue;
  TMyJsonArray: TJSONArray;
  TMyJsonString: TJSONString;

  TMyPostData: string;




implementation

{$R *.fmx}
{$R *.Windows.fmx MSWINDOWS}
{$R *.Macintosh.fmx MACOS}

procedure TTMySimpleChatGPTForm.TMySimpleChatGPTButtonClick(Sender: TObject);
begin
  TMySimpleChatGPTMemo.HTML.Text := TMyAskChatGPT(TMySimpleChatGPTEdit.Text, TMySimpleChatGPTComboBox.Text);
end;

procedure TTMySimpleChatGPTForm.TMySimpleChatGPTComboBoxItemSelected(
  Sender: TObject; AText: string; AItemIndex: Integer);
var
    TMyCBHint: string;

begin
  if (TMySimpleChatGPTEdit.Text <> '') and (TMySimpleChatGPTComboBox.Text <> '') then
    TMySimpleChatGPTButton.Enabled := True;
  TMySimpleChatGPTModel := AText;
  // Delete quotin marks for request path
  Delete(AText,1,1);
  Delete(AText, AText.Length,1);
  TMyCB := TTMSFNCCloudBase.Create;
  try
    TMyCB.Request.AddHeader('Authorization','Bearer ' + GetOpenApiKey);
    TMyCB.Request.Method := rmGET;
    TMyCB.Request.Host := OPENAIHOST;
    TMyCB.Request.Path := OPENAIAPIVERV1 + 'models/' + AText;

    TMyCB.ExecuteRequest(nil, nil, False);

    if TMyCB.RequestResult.Success then
    begin
      TMyJsonValue := TJSONObject.ParseJSONValue(TMyCB.RequestResult.ResultString);

      TMyCBHint := 'Object:' + TMyJsonValue.GetValue<TJSONValue>('object').ToString;
      TMyCBHint := TMyCBHint + ' Owned by:' + TMyJsonValue.GetValue<TJSONValue>('owned_by').ToString;
      TMyCBHint := TMyCBHint + ' permission:' + TMyJsonValue.GetValue<TJSONValue>('permission').ToString;
      TMySimpleChatGPTComboBox.Hint := TMyCBHint;
    end
    else
      raise Exception.Create('ItemSelected HTTP response code:' + TMyCB.RequestResult.ResponseCode.ToString);
  finally
    TMyCB.Free;
  end;
end;

procedure TTMySimpleChatGPTForm.TMySimpleChatGPTFormCreate(Sender: TObject);
var
    TMyJsonItem: TJSONValue;

begin
    TMySimpleChatGPTButton.Enabled := False;
    TMySimpleChatGPTEdit.Text := TMySimpleChatGPTEdit.Text.Empty;
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
          TMySimpleChatGPTComboBox.Items.Sort;
        end;
      end
      else
        raise Exception.Create('FormCreate HTTP reponse code: ' + TMyCB.RequestResult.ResponseCode.ToString);
    finally
      TMyCB.Free;
    end;
end;

function TTMySimpleChatGPTForm.TMyAskChatGPT(AQuestion: string; AModel: string): string;
var
  TMyJsonItem: TJSONValue;
  TMyJsonStringValues: string;

begin
  Result := '';

  TMyPostData := '{' +
    '"model": ' + TMySimpleChatGPTModel + ','+
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
          //TMyJsonString := TMyJsonArray.Items[0].GetValue<TJSONString>('text');
          for TMyJsonItem in TMyJsonArray do
          begin
            TMyJsonString := TMyJsonItem.GetValue<TJSONString>('text');
            TMyJsonStringValues := TMyJsonStringValues + #13#10 +TMyJsonString.Value
          end;

          Result := TMyJsonString.Value;
        end
      end
      else
        raise Exception.Create('AskCHatGPT HTTP response code: ' + TMyCB.RequestResult.ResponseCode.ToString);
    finally
      TMyCB.Free;
    end;
end;

end.
