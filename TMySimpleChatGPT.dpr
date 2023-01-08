program TMySimpleChatGPT;

uses
  System.StartUpCopy,
  FMX.Forms,
  TMySimpleChatGPTUnit in 'TMySimpleChatGPTUnit.pas' {TMySimpleChatGPTForm},
  TMyChatGPTAPIKeyUnit in 'TMyChatGPTAPIKeyUnit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TTMySimpleChatGPTForm, TMySimpleChatGPTForm);
  Application.Run;
end.
