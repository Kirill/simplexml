program Test;

uses
  Forms,
  TestForms in 'TestForms.pas' {TestForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TTestForm, TestForm);
  Application.Run;
end.
