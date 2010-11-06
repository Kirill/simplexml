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
	//	Создаем пустой документ XML
	aDoc := CreateXmlDocument;

	//	Считываем из файла
	aDoc.Load(ExtractFilePath(ParamStr(0)) + '\Test.xml');

	//	Выводим в Memo1 полный текст считаного XML
	Memo1.Lines.Text := aDoc.Xml;

	Memo1.Lines.Add('------------------------');

	//	Ищем первый элемент с тэгом 'elem2'
	anElem2 := aDoc.DocumentElement.SelectSingleNode('elem2');

	//	Выводим в Memo1 XML-текст элемента anElem2
	Memo1.Lines.Add(anElem2.Xml);

	Memo1.Lines.Add('------------------------');

	//	Выводим в Memo1 значение атрибута 'a2' элемента anElem2
	Memo1.Lines.Add(anElem2.GetAttr('a2'));
end;

procedure TTestForm.Button2Click(Sender: TObject);
var
	aDoc: IXmlDocument;
	anElem: IXmlElement;
begin
	//	Создаем пустой документ XML с корневым элементом "root-element"
	aDoc := CreateXmlDocument('xml');

	//	Создаем элемент 'elem' и добавляем его в качестве дочернего элемента для корневого
	anElem := aDoc.DocumentElement.AppendElement('elem');

	//	Добавляем атрибуты 'a1' и 'a2' к новому элементу
	anElem.SetAttr('a1', 'elem1 a1');
	anElem.SetAttr('a2', 'elem1 a2');

	//	Добавляем еще один элемент 'elem'
	anElem := aDoc.DocumentElement.AppendElement('elem');
	anElem.SetAttr('a1', 'elem2 a1');
	anElem.SetAttr('a2', 'elem2 a2');

	//	Сохраняем документ в файл
	aDoc.Save(ExtractFilePath(ParamStr(0)) + '\Test2.xml');
end;

end.
