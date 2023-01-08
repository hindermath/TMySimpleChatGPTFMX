program TMySimpleChatGPT;

uses
  System.StartUpCopy,
  FMX.Forms,
  TMySimpleChatGPTUnit in 'TMySimpleChatGPTUnit.pas' {TMySimpleChatGPTForm},
  TMyChatGPTAPIKey2Unit in 'TMyChatGPTAPIKey2Unit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TTMySimpleChatGPTForm, TMySimpleChatGPTForm);
  Application.Run;
end.
