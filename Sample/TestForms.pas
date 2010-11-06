unit TestForms;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, SimpleXML, StdCtrls;

type
  TTestForm = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  TestForm: TTestForm;

implementation

{$R *.dfm}

procedure TTestForm.Button1Click(Sender: TObject);
var
	aDoc: IXmlDocument;
	anElem2: IXmlNode;
begin
	//	������� ������ �������� XML
	aDoc := CreateXmlDocument;

	//	��������� �� �����
	aDoc.Load(ExtractFilePath(ParamStr(0)) + '\Test.xml');

	//	������� � Memo1 ������ ����� ��������� XML
	Memo1.Lines.Text := aDoc.Xml;

	Memo1.Lines.Add('------------------------');

	//	���� ������ ������� � ����� 'elem2'
	anElem2 := aDoc.DocumentElement.SelectSingleNode('elem2');

	//	������� � Memo1 XML-����� �������� anElem2
	Memo1.Lines.Add(anElem2.Xml);

	Memo1.Lines.Add('------------------------');

	//	������� � Memo1 �������� �������� 'a2' �������� anElem2
	Memo1.Lines.Add(anElem2.GetAttr('a2'));
end;

procedure TTestForm.Button2Click(Sender: TObject);
var
	aDoc: IXmlDocument;
	anElem: IXmlElement;
begin
	//	������� ������ �������� XML � �������� ��������� "root-element"
	aDoc := CreateXmlDocument('xml');

	//	������� ������� 'elem' � ��������� ��� � �������� ��������� �������� ��� ���������
	anElem := aDoc.DocumentElement.AppendElement('elem');

	//	��������� �������� 'a1' � 'a2' � ������ ��������
	anElem.SetAttr('a1', 'elem1 a1');
	anElem.SetAttr('a2', 'elem1 a2');

	//	��������� ��� ���� ������� 'elem'
	anElem := aDoc.DocumentElement.AppendElement('elem');
	anElem.SetAttr('a1', 'elem2 a1');
	anElem.SetAttr('a2', 'elem2 a2');

	//	��������� �������� � ����
	aDoc.Save(ExtractFilePath(ParamStr(0)) + '\Test2.xml');
end;

end.
