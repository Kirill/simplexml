unit SimpleXML;

interface

uses
	Windows, SysUtils, Classes;

const
	BINXML_USE_WIDE_CHARS = 1;

	XSTR_NULL = '{{null}}';

	NODE_INVALID = $00000000;
	NODE_ELEMENT = $00000001;
	NODE_ATTRIBUTE = $00000002;
	NODE_TEXT = $00000003;
	NODE_CDATA_SECTION = $00000004;
	NODE_ENTITY_REFERENCE = $00000005;
	NODE_ENTITY = $00000006;
	NODE_PROCESSING_INSTRUCTION = $00000007;
	NODE_COMMENT = $00000008;
	NODE_DOCUMENT = $00000009;
	NODE_DOCUMENT_TYPE = $0000000A;
	NODE_DOCUMENT_FRAGMENT = $0000000B;
	NODE_NOTATION = $0000000C;

{$if CompilerVersion < 20}
type
  UnicodeString = WideString;
  RawByteString = AnsiString;
  PByte = PAnsiChar;
{$ifend}

type
	IXmlDocument = interface;
	IXmlElement = interface;
	IXmlText = interface;
	IXmlCDATASection = interface;
	IXmlComment = interface;
	IXmlProcessingInstruction = interface;


	// IXmlBase - базовый интерфейс для всех интерфейсов SimpleXML.
	IXmlBase = interface
		// GetObject - возвращает ссылку на объект, реализующий интерфейс.
		function GetObject: TObject;
	end;

	// IXmlNameTable - таблица имен. Каждому имени сопоставляется некий
	//  уникальный числовой идентификатор. Используется для хранения
	//  названий тэгов и атрибутов.
	IXmlNameTable = interface(IXmlBase)
		// GetID - возвращает числовой идентификатор указанной строки.
		function GetID(const aName: String): Integer;
		// GetID - возвращает строку, соответствующую указанному числовому
		//  идентификатору.
		function GetName(anID: Integer): String;
	end;

	IXmlNode = interface;

	TXmlCompareNodes = function(const aNode1, aNode2: IXmlNode): Integer;

	// IXmlNodeList - список узлов. Список организован в виде массива.
	//  Доступ к элементам списка по индексу
	IXmlNodeList = interface(IXmlBase)
		// Get_Count - количество узлов в списке
		function Get_Count: Integer;
		// Get_Item - получить узел по индексу
		function Get_Item(anIndex: Integer): IXmlNode;
		// Get_XML - возвращает представление элементов списка в формате XML
		function Get_XML: String;

		procedure SortElements(aCompare: TXmlCompareNodes);
		function IndexOf(const aNode: IXmlNode): Integer;
    procedure Add(const aNode: IXmlNode);
		procedure Insert(const aNode: IXmlNode; anIndex: Integer);
		function Remove(const aNode: IXmlNode): Integer;
		procedure Delete(anIndex: Integer);
		procedure Clear;

		property Count: Integer read Get_Count;
		property Item[anIndex: Integer]: IXmlNode read Get_Item; default;
		property XML: String read Get_XML;
	end;

	// IXmlNode - узел XML-дерева
	IXmlNode = interface(IXmlBase)
		function Get_SourceLine: Integer;
		function Get_SourceCol: Integer;

		// Get_NameTable - таблица имен, используемая данным узлом
		function Get_NameTable: IXmlNameTable;
		// Get_NodeName - возвращает название узла. Интерпретация названия узла
		//  зависит от его типа
		function Get_NodeName: String;
		// Get_NodeNameID - возвращает код названия узла
		function Get_NodeNameID: Integer;
		// Get_NodeType - возвращает тип узла
		function Get_NodeType: Integer;
		// Get_Text - возвращает текст узла
		function Get_Text: String;
		// Set_Text - изменяет текст узла
		procedure Set_Text(const aValue: String);
		// Get_DataType - возаращает тип данных узла в терминах вариантов
		function Get_DataType: Integer;
		// Get_TypedValue - возвращает 
		function Get_TypedValue: Variant;
		// Set_TypedValue - изменяет текст узла на типизированное значение
		procedure Set_TypedValue(const aValue: Variant);
		// Get_XML - возвращает представление узла и всех вложенных узлов
		//  в формате XML.
		function Get_XML: String;

		// CloneNode - создает точную копию данного узла
		//  Если задан признак aDeep, то создастся копия
		//  всей ветви иерархии от данного узла.
		function CloneNode(aDeep: Boolean = True): IXmlNode;

		// Get_ParentNode - возвращает родительский узел
		function Get_ParentNode: IXmlNode;
		// Get_OwnerDocument - возвращает XML-документ,
		//  в котором расположен данный узел
		function Get_OwnerDocument: IXmlDocument;

    function Get_NextSibling: IXmlNode;

		// Get_ChildNodes - возвращает список дочерних узлов
		function Get_ChildNodes: IXmlNodeList;
		// AppendChild - добавляет указанный узел в конец списка дочерних узлов
		procedure AppendChild(const aChild: IXmlNode);
		// InsertBefore - добавляет указанный узел в указанное место списка дочерних узлов
		procedure InsertBefore(const aChild, aBefore: IXmlNode);
		// ReplaceChild - заменяет указанный узел другим узлом
		procedure ReplaceChild(const aNewChild, anOldChild: IXmlNode);
		// RemoveChild - удаляет указанный узел из списка дочерних узлов
		procedure RemoveChild(const aChild: IXmlNode);

		// AppendElement - создает элемент и добавляет его в конец списка
		//  в конец списка дочерних объектов
		function AppendElement(aNameID: Integer): IXmlElement; overload;
		function AppendElement(const aName: String): IXmlElement; overload;

		// AppendText - создает текстовый узел и добавляет его 
		//  в конец списка дочерних объектов
		function AppendText(const aData: String): IXmlText;

		// AppendCDATA - создает секцию CDATA и добавляет ее 
		//  в конец списка дочерних объектов
		function AppendCDATA(const aData: String): IXmlCDATASection;

		// AppendComment - создает комментарий и добавляет его 
		//  в конец списка дочерних объектов
		function AppendComment(const aData: String): IXmlComment;

		// AppendProcessingInstruction - создает инструкцию и добавляет её
		//  в конец списка дочерних объектов
		function AppendProcessingInstruction(aTargetID: Integer;
			const aData: String): IXmlProcessingInstruction; overload;
		function AppendProcessingInstruction(const aTarget: String;
			const aData: String): IXmlProcessingInstruction; overload;
		
		// GetChildText - возвращает значение дочернего узла
		// SetChildText - добавляет или изменяет значение дочернего узла
		function GetChildText(const aName: String; const aDefault: String = ''): String; overload;
		function GetChildText(aNameID: Integer; const aDefault: String = ''): String; overload;
		procedure SetChildText(const aName, aValue: String); overload;
		procedure SetChildText(aNameID: Integer; const aValue: String); overload;

		// NeedChild - возвращает дочерний узел с указанным именем.
		//  Если узел не найден, то генерируется исключение
		function NeedChild(aNameID: Integer): IXmlNode; overload;
		function NeedChild(const aName: String): IXmlNode; overload;

		// EnsureChild - возвращает дочерний узел с указанным именем.
		//  Если узел не найден, то он будет создан
		function EnsureChild(aNameID: Integer): IXmlNode; overload;
		function EnsureChild(const aName: String): IXmlNode; overload;

		// RemoveAllChilds - удаляет все дочерние узлы
		procedure RemoveAllChilds;

		// SelectNodes - производит выборку узлов, удовлетворяющих
		//  указанным критериям
		function SelectNodes(const anExpression: String): IXmlNodeList; overload;
		function SelectNodes(aNodeNameID: Integer): IXmlNodeList; overload;
		// SelectSingleNode - производит поиск первого узла, удовлетворяющего
		//  указанным критериям
		function SelectSingleNode(const anExpression: String): IXmlNode;
		// FindElement - производит поиск первого узла, удовлетворяющего
		//  указанным критериям
		function FindElement(const anElementName, anAttrName: String; const anAttrValue: Variant): IXmlElement;
		function FindElements(const anElementName, anAttrName: String; const anAttrValue: Variant): IXmlNodeList;

		// Get_AttrCount - возвращает количество атрибутов
		function Get_AttrCount: Integer;
		// Get_AttrNameID - возвращает код названия атрибута
		function Get_AttrNameID(anIndex: Integer): Integer;
		// Get_AttrName - возвращает название атрибута
		function Get_AttrName(anIndex: Integer): String;
		// RemoveAttr - удаляет атрибут
		procedure RemoveAttr(const aName: String); overload;
		procedure RemoveAttr(aNameID: Integer); overload;
		// RemoveAllAttrs - удаляет все атрибуты
		procedure RemoveAllAttrs;

		// AttrExists - проверяет, задан ли указанный атрибут.
		function AttrExists(aNameID: Integer): Boolean; overload;
		function AttrExists(const aName: String): Boolean; overload;

		// GetAttrType - возаращает тип данных атрибута в терминах вариантов
		function GetAttrType(aNameID: Integer): Integer; overload;
		function GetAttrType(const aName: String): Integer; overload;

		// GetAttrType - возвращает тип атрибута
		//  Result
		// GetVarAttr - возвращает типизированное значение указанного атрибута.
		//  Если атрибут не задан, то возвращается значение по умолчанию
		// SetAttr - изменяет или добавляет указанный атрибут
		function GetVarAttr(aNameID: Integer; const aDefault: Variant): Variant; overload;
		function GetVarAttr(const aName: String; const aDefault: Variant): Variant; overload;
		procedure SetVarAttr(aNameID: Integer; const aValue: Variant); overload;
		procedure SetVarAttr(const aName: String; aValue: Variant); overload;
		function NeedVarAttr(aNameID: Integer): Variant; overload;
		function NeedVarAttr(const aName: String): Variant; overload;

		// NeedAttr - возвращает строковое значение указанного атрибута.
		//  Если атрибут не задан, то генерируется исключение
		function NeedAttr(aNameID: Integer): String; overload;
		function NeedAttr(const aName: String): String; overload;

		// GetAttr - возвращает строковое значение указанного атрибута.
		//  Если атрибут не задан, то возвращается значение по умолчанию
		// SetAttr - изменяет или добавляет указанный атрибут
		function GetAttr(aNameID: Integer; const aDefault: String = ''): String; overload;
		function GetAttr(const aName: String; const aDefault: String = ''): String; overload;
		procedure SetAttr(aNameID: Integer; const aValue: String); overload;
		procedure SetAttr(const aName, aValue: String); overload;

		// GetBoolAttr - возвращает целочисленное значение указанного атрибута
		// SetBoolAttr - изменяет или добавляет указанный атрибут целочисленным
		//  значением
		function GetBoolAttr(aNameID: Integer; aDefault: Boolean = False): Boolean; overload;
		function GetBoolAttr(const aName: String; aDefault: Boolean = False): Boolean; overload;
		procedure SetBoolAttr(aNameID: Integer; aValue: Boolean = False); overload;
		procedure SetBoolAttr(const aName: String; aValue: Boolean); overload;

		// GetIntAttr - возвращает целочисленное значение указанного атрибута
		// SetIntAttr - изменяет или добавляет указанный атрибут целочисленным
		//  значением
		function GetIntAttr(aNameID: Integer; aDefault: Integer = 0): Integer; overload;
		function GetIntAttr(const aName: String; aDefault: Integer = 0): Integer; overload;
    function NeedIntAttr(const aName: String): Integer; overload;
    function NeedIntAttr(aNameID: Integer): Integer; overload;

		procedure SetIntAttr(aNameID: Integer; aValue: Integer); overload;
		procedure SetIntAttr(const aName: String; aValue: Integer); overload;



		// GetDateTimeAttr - возвращает целочисленное значение указанного атрибута
		// SetDateTimeAttr - изменяет или добавляет указанный атрибут целочисленным
		//  значением
		function GetDateTimeAttr(aNameID: Integer; aDefault: TDateTime = 0): TDateTime; overload;
		function GetDateTimeAttr(const aName: String; aDefault: TDateTime = 0): TDateTime; overload;
		procedure SetDateTimeAttr(aNameID: Integer; aValue: TDateTime); overload;
		procedure SetDateTimeAttr(const aName: String; aValue: TDateTime); overload;

		// GetFloatAttr - возвращает значение указанного атрибута в виде
		//  вещественного числа
		// SetFloatAttr - изменяет или добавляет указанный атрибут вещественным
		//  значением
		function GetFloatAttr(aNameID: Integer; aDefault: Double = 0): Double; overload;
		function GetFloatAttr(const aName: String; aDefault: Double = 0): Double; overload;

		function NeedFloatAttr(aNameID: Integer): Double; overload;
		function NeedFloatAttr(const aName: String): Double; overload;

		procedure SetFloatAttr(aNameID: Integer; aValue: Double); overload;
		procedure SetFloatAttr(const aName: String; aValue: Double); overload;

		// GetHexAttr - получение значения указанного атрибута в целочисленном виде.
		//  Строковое значение атрибута преобразуется в целое число. Исходная
		//  строка должна быть задана в шестнадцатиричном виде без префиксов
		//  ("$", "0x" и пр.) Если преобразование не может быть выполнено,
		//  генерируется исключение.
		//  Если атрибут не задан, возвращается значение параметра aDefault.
		// SetHexAttr - изменение значения указанного атрибута на строковое
		//  представление целого числа в шестнадцатиричном виде без префиксов
		//		("$", "0x" и пр.) Если преобразование не может быть выполнено,
		//		генерируется исключение.
		//		Если атрибут не был задан, до он будет добавлен.
		//		Если был задан, то будет изменен.
		function GetHexAttr(const aName: String; aDefault: Integer = 0): Integer; overload;
		function GetHexAttr(aNameID: Integer; aDefault: Integer = 0): Integer; overload;
		procedure SetHexAttr(const aName: String; aValue: Integer; aDigits: Integer = 8); overload;
		procedure SetHexAttr(aNameID: Integer; aValue: Integer; aDigits: Integer = 8); overload;

		//	GetEnumAttr - ищет значение атрибута в указанном списке строк и
		//		возвращает индекс	найденной строки. Если атрибут задан но не найден
		//		в списке, то генерируется исключение.
		//		Если атрибут не задан, возвращается значение параметра aDefault.
		function GetEnumAttr(const aName: String;
			const aValues: array of String; aDefault: Integer = 0): Integer; overload;
		function GetEnumAttr(aNameID: Integer;
			const aValues: array of String; aDefault: Integer = 0): Integer; overload;

		function NeedEnumAttr(const aName: String;
			const aValues: array of String): Integer; overload;
		function NeedEnumAttr(aNameID: Integer;
			const aValues: array of String): Integer; overload;

		//	ReplaceTextByCDATASection - удаляет все текстовые элементы и добавляет
		//		одну секцию CDATA, содержащую указанный текст
		procedure ReplaceTextByCDATASection(const aText: String);

		//	ReplaceTextByBinaryData - удаляет все текстовые элементы и добавляет
		//		один текстовый элемент, содержащий указанные двоичные данные
		//		в формате "base64".
		//		Если параметр aMaxLineLength не равен нулю, то производится разбивка
		//		полученой строки на строки длиной aMaxLineLength.
		//		Строки разделяются парой символов #13#10 (CR,LF).
		//		После последней строки указанные символы не вставляются.
		procedure ReplaceTextByBinaryData(const aData; aSize: Integer;
			aMaxLineLength: Integer);

		//	GetTextAsBinaryData - cобирает все текстовые элементы в одну строку и
		//		производит преобразование из формата "base64" в двоичные данные.
		//		При преобразовании игнорируются все пробельные символы (с кодом <= ' '),
		//		содержащиеся в исходной строке.
		function GetTextAsBinaryData: RawByteString;

		function GetOwnText: String;

		function Get_Values(const aName: String): Variant;
		procedure Set_Values(const aName: String; const aValue: Variant);

		function AsElement: IXmlElement;
		function AsText: IXmlText;
		function AsCDATASection: IXmlCDATASection;
		function AsComment: IXmlComment;
		function AsProcessingInstruction: IXmlProcessingInstruction;

		property SourceLine: Integer read Get_SourceLine;
		property SourceCol: Integer read Get_SourceCol;
		property NodeName: String read Get_NodeName;
		property NodeNameID: Integer read Get_NodeNameID;
		property NodeType: Integer read Get_NodeType;
		property ParentNode: IXmlNode read Get_ParentNode;
		property OwnerDocument: IXmlDocument read Get_OwnerDocument;
    property NextSibling: IXmlNode read Get_NextSibling;
		property NameTable: IXmlNameTable read Get_NameTable;
		property ChildNodes: IXmlNodeList read Get_ChildNodes;
		property AttrCount: Integer read Get_AttrCount;
		property AttrNames[anIndex: Integer]: String read Get_AttrName;
		property AttrNameIDs[anIndex: Integer]: Integer read Get_AttrNameID;
		property Text: String read Get_Text write Set_Text;
		property DataType: Integer read Get_DataType;
		property TypedValue: Variant read Get_TypedValue write Set_TypedValue;
		property Xml: String read Get_Xml;
		property Values[const aName: String]: Variant read Get_Values write Set_Values; default;
	end;

	IXmlElement = interface(IXmlNode)
	end;

	IXmlCharacterData = interface(IXmlNode)
	end;

	IXmlText = interface(IXmlCharacterData)
	end;

	IXmlCDATASection = interface(IXmlCharacterData)
	end;

	IXmlComment = interface(IXmlCharacterData)
	end;

	IXmlProcessingInstruction = interface(IXmlNode)
		function Get_Target: String;

		property Target: String read Get_Target;
	end;

	IXmlDocument = interface(IXmlNode)
		function Get_DocumentElement: IXmlElement;
		function Get_BinaryXML: RawByteString;
		function Get_PreserveWhiteSpace: Boolean;
		procedure Set_PreserveWhiteSpace(aValue: Boolean);

		function NewDocument(const aVersion, anEncoding: String;
			aRootElementNameID: Integer): IXmlElement; overload;
		function NewDocument(const aVersion, anEncoding,
			aRootElementName: String): IXmlElement; overload;

		function CreateElement(aNameID: Integer): IXmlElement; overload;
		function CreateElement(const aName: String): IXmlElement; overload;
		function CreateText(const aData: String): IXmlText;
		function CreateCDATASection(const aData: String): IXmlCDATASection;
		function CreateComment(const aData: String): IXmlComment;
		function CreateProcessingInstruction(const aTarget,
			aData: String): IXmlProcessingInstruction; overload;
		function CreateProcessingInstruction(aTargetID: Integer;
			const aData: String): IXmlProcessingInstruction; overload;

		procedure LoadXML(const anXml: String); overload;
    {$if CompilerVersion >= 20}
		procedure LoadXML(const anXml: RawByteString); overload;
    {$ifend}
		procedure LoadBinaryXML(const anXml: RawByteString);

		procedure Load(aStream: TStream); overload;
		procedure Load(const aFileName: String); overload;

		procedure LoadResource(aType, aName: PChar);

		procedure Save(aStream: TStream); overload;
		procedure Save(const aFileName: String); overload;

		procedure SaveBinary(aStream: TStream; anOptions: LongWord = 0); overload;
		procedure SaveBinary(const aFileName: String; anOptions: LongWord = 0); overload;

		property PreserveWhiteSpace: Boolean read Get_PreserveWhiteSpace write Set_PreserveWhiteSpace;
		property DocumentElement: IXmlElement read Get_DocumentElement;
		property BinaryXML: RawByteString read Get_BinaryXML;
	end;

function CreateNameTable(aHashTableSize: Integer = 4096): IXmlNameTable;
function CreateXmlDocument(
	const aRootElementName: String = '';
	const aVersion: String = '1.0';
	const anEncoding: String = ''; // SimpleXmlDefaultEncoding
	const aNames: IXmlNameTable = nil): IXmlDocument;

function CreateXmlElement(const aName: String; const aNameTable: IXmlNameTable = nil): IXmlElement;
function CreateXmlNodeList: IXmlNodeList;
function LoadXmlDocumentFromXml(const anXml: String): IXmlDocument;
function LoadXmlDocumentFromBinaryXML(const aBinaryXml: RawByteString): IXmlDocument;

function LoadXmlDocument(aStream: TStream): IXmlDocument; overload;
function LoadXmlDocument(const aFileName: String): IXmlDocument; overload;
function LoadXmlDocument(aResType, aResName: PChar): IXmlDocument; overload;

var
	DefaultNameTable: IXmlNameTable = nil;
	DefaultPreserveWhiteSpace: Boolean = False;
	DefaultEncoding: String = 'windows-1251';
	DefaultIndentText: String = ^I;

resourcestring
	SSimpleXmlError1 = 'Ошибка получения элемента списка: индекс выходит за пределы';
	SSimpleXmlError2 = 'Не завершено определение элемента';
	SSimpleXmlError3 = 'Некорретный символ в имени элемента';
	SSimpleXmlError4 = 'Ошибка чтения двоичного XML: некорректный тип узла';
	SSimpleXmlError5 = 'Ошибка записи двоичного XML: некорректный тип узла';
	SSimpleXmlError6 = 'Неверное значение атрибута "%s" элемента "%s".'^M^J +
		'Допустимые значения:'^M^J +
		'%s';
	SSimpleXmlError7 = 'Не найден атрибут "%s"';
	SSimpleXmlError8 = 'Не задан атрибут "%s"';
	SSimpleXmlError9 = 'Данная возможность не поддерживается SimpleXML';
	SSimpleXmlError10 = 'Ошибка: не найден дочерний элемент "%s".';
	SSimpleXmlError11 = 'Имя должно начинаться с буквы или "_" (стр. %d, поз. %d)';
	SSimpleXmlError12 = 'Ожидается число (стр. %d, поз. %d)';
	SSimpleXmlError13 = 'Ожидается шестнадцатеричное число (стр. %d, поз. %d)';
	SSimpleXmlError14 = 'Ожидается "#" или имя упрамляющего символа (стр. %d, поз. %d)';
	SSimpleXmlError15 = 'Некорректное имя управляющего символа (стр. %d, поз. %d)';
	SSimpleXmlError16 = 'Ожидается "%s" (стр. %d, поз. %d)';
	SSimpleXmlError17 = 'Ожидается "%s" (стр. %d, поз. %d)';
	SSimpleXmlError18 = 'Символ "<" не может использоваться в значениях атрибутов (стр. %d, поз. %d)';
	SimpleXmlError19 = 'Ожидается "%s" (стр. %d, поз. %d)';
	SSimpleXmlError20 = 'Ожидается значение атрибута (стр. %d, поз. %d)';
	SSimpleXmlError21 = 'Ожидается строковая константа (стр. %d, поз. %d)';
	SimpleXmlError22 = 'Ожидается "%s" (стр. %d, поз. %d)';
	SSimpleXmlError23 = 'Ошибка чтения данных.';
	SSimpleXmlError24 = 'Ошибка чтения значения: некорректный тип.';
	SSimpleXmlError25 = 'Ошибка записи значения: некорректный тип.';
	SSimpleXmlError26 = '%s (файл: "%s")';
	SSimpleXmlError27 = 'Ошибка установки значения атрибута: не задано имя.';

function XSTRToFloat(s: String): Double;
function FloatToXSTR(v: Double): String;
function DateTimeToXSTR(v: TDateTime): String;
function VarToXSTR(const v: TVarData): String;

function TextToXML(const aText: String): String;
function BinToBase64(const aBin; aSize, aMaxLineLength: Integer): String;
function Base64ToBin(const aBase64: String): RawByteString;

function IsXmlDataString(const aData: RawByteString): Boolean;
function XmlIsInBinaryFormat(const aData: RawByteString): Boolean;

function AppendChildNodeFromXml(const aParentNode: IXmlNode; const anXml: String): IXmlNode;

implementation

uses
	Variants, DateUtils;

const
	BinXmlSignatureSize = Length('< binary-xml >');
	BinXmlSignature: RawByteString = '< binary-xml >';

type
  TStringBuilder = object
  private
    FData: String;
    FLength: Integer;
  public
    procedure Init;
    procedure Add(const s: String);
    procedure GetString(var aString: String);
  end;

{ TStringBuilder }

procedure TStringBuilder.Init;
begin
  FData := '';
  FLength := 0;
end;

procedure TStringBuilder.Add(const s: String);
var
  anAddLength,
  aNewLength: Integer;
begin
  anAddLength := Length(s);
  if anAddLength = 0 then begin
    Exit;
  end;

  aNewLength := FLength + anAddLength;
  if aNewLength > Length(FData) then begin
    if aNewLength > 64 then begin
      SetLength(FData, aNewLength + aNewLength div 4)
    end
    else if aNewLength > 8 then begin
      SetLength(FData, aNewLength + 16)
    end
    else begin
      SetLength(FData, aNewLength + 4);
    end
  end;
  Move(s[1], FData[FLength + 1], anAddLength*sizeof(Char));
  FLength := aNewLength;
end;

procedure TStringBuilder.GetString(var aString: String);
begin
  aString := Copy(FData, 1, FLength);
end;

procedure CopyChars(const aFrom: String; var aTo: String; var aPos: Integer);
begin
  Move(aFrom[1], aTo[aPos], Length(aFrom)*sizeof(Char));
  Inc(aPos, Length(aFrom));
end;

function TextToXML(const aText: String): String;
var
	i, j: Integer;
begin
	j := 0;
	for i := 1 to Length(aText) do begin
		case aText[i] of
			'<', '>': Inc(j, 4);
			'&': Inc(j, 5);
			'"': Inc(j, 6);
			else begin
				Inc(j);
      end
		end;
  end;

	if j = Length(aText) then begin
		Result := aText
  end
	else begin
		SetLength(Result, j);
		j := 1;
		for i := 1 to Length(aText) do begin
			case aText[i] of
				'<': begin CopyChars('&lt;', Result, j) end;
				'>': begin CopyChars('&gt;', Result, j) end;
				'&': begin CopyChars('&amp;', Result, j) end;
				'"': begin CopyChars('&quot;', Result, j) end;
				else begin Result[j] := aText[i]; Inc(j) end;
			end;
    end;
	end;
end;

function XSTRToFloat(s: String): Double;
var
	aPos: Integer;
  fmt : TFormatSettings;
begin
  GetLocaleFormatSettings(LOCALE_SYSTEM_DEFAULT, fmt);
	if '.' = fmt.DecimalSeparator then begin
		aPos := Pos(',', s)
  end
	else if ',' = fmt.DecimalSeparator then begin
		aPos := Pos('.', s)
  end
	else begin
		aPos := Pos(',', s);
		if aPos = 0 then begin
			aPos := Pos('.', s);
    end
	end;

	if aPos <> 0 then begin
		s[aPos] := fmt.DecimalSeparator;
  end;
	Result := StrToFloat(s);
end;

function FloatToXSTR(v: Double): String;
var
	aPos: Integer;
  fmt : TFormatSettings;
begin
	Result := FloatToStr(v);
  GetLocaleFormatSettings(LOCALE_SYSTEM_DEFAULT, fmt);
	aPos := Pos(fmt.DecimalSeparator, Result);
	if aPos <> 0 then begin
		Result[aPos] := '.';
  end;
end;

function IsDigit(c: Char): Boolean;
begin
  Result := (c >= '0') and (c <= '9')
end;

function XSTRToDateTime(const s: String): TDateTime;
var
	aPos: Integer;

	function FetchTo(aStop: Char): Integer;
	var
		i: Integer;
	begin
		i := aPos;
		while (i <= Length(s)) and IsDigit(s[i]) do begin
			Inc(i);
    end;
		if i > aPos then
			Result := StrToInt(Copy(s, aPos, i - aPos))
		else
			Result := 0;
		if (i <= Length(s)) and (s[i] = aStop) then
			aPos := i + 1
		else
			aPos := Length(s) + 1;
	end;

var
	y, m, d, h, n, ss: Integer;
begin
	aPos := 1;
	y := FetchTo('-'); m := FetchTo('-'); d := FetchTo('T');
	h := FetchTo('-'); n := FetchTo('-'); ss := FetchTo('-');
	Result := EncodeDateTime(y, m, d, h, n, ss, 0);
end;

function DateTimeToXSTR(v: TDateTime): String;
var
	y, m, d, h, n, s, ms: Word;
begin
	DecodeDateTime(v, y, m, d, h, n, s, ms);
	Result := Format('%.4d-%.2d-%.2dT%.2d:%.2d:%.2d', [y, m, d, h, n, s])
end;

function VarToXSTR(const v: TVarData): String;
const
	BoolStr: array[Boolean] of String = ('0', '1');
var
	p: Pointer;
begin
	case v.VType of
		varNull: Result := XSTR_NULL;
		varSmallint: Result := IntToStr(v.VSmallInt);
		varInteger: Result := IntToStr(v.VInteger);
		varSingle: Result := FloatToXSTR(v.VSingle);
		varDouble: Result := FloatToXSTR(v.VDouble);
		varCurrency: Result := FloatToXSTR(v.VCurrency);
		varDate: Result := DateTimeToXSTR(v.VDate);
		varOleStr: Result := v.VOleStr;
		varBoolean: Result := BoolStr[v.VBoolean = True];
		varShortInt: Result := IntToStr(v.VShortInt);
		varByte: Result := IntToStr(v.VByte);
		varWord: Result := IntToStr(v.VWord);
		varLongWord: Result := IntToStr(v.VLongWord);
		varInt64: Result := IntToStr(v.VInt64);
		varString: Result := String(AnsiString(v.VString));
    {$if CompilerVersion >= 20}
		varUString: Result := String(v.VString);
    {$ifend}
		varArray + varByte: begin
      p := VarArrayLock(Variant(v));
      try
        Result := BinToBase64(p^, VarArrayHighBound(Variant(v), 1) - VarArrayLowBound(Variant(v), 1) + 1, 0);
      finally
        VarArrayUnlock(Variant(v))
      end
    end;
		else begin
			Result := Variant(v)
    end
	end;
end;

function LoadXMLResource(aModule: HMODULE; aName, aType: PChar; const aXMLDoc: IXmlDocument): boolean;
var
	aRSRC: HRSRC;
	aGlobal: HGLOBAL;
	aSize: DWORD;
	aPointer: Pointer;

	aStream: TStringStream;
begin
	Result := false;

	aRSRC := FindResource(aModule, aName, aType);
	if aRSRC <> 0 then begin
		aGlobal := LoadResource(aModule, aRSRC);
		aSize := SizeofResource(aModule, aRSRC);
		if (aGlobal <> 0) and (aSize <> 0) then begin
			aPointer := LockResource(aGlobal);
			if Assigned(aPointer) then begin
				aStream := TStringStream.Create('');
				try
					aStream.WriteBuffer(aPointer^, aSize);
					aXMLDoc.LoadXML(aStream.DataString);
					Result := true;
				finally
					aStream.Free;
				end;
			end;
		end;
	end;
end;




function IsWhitespace(c: Char): Boolean;
begin
  Result := c <= ' ';
end;




function IsAnsiWhitespace(c: AnsiChar): Boolean;
begin
  Result := c <= ' ';
end;




function IsXmlDataString(const aData: RawByteString): Boolean;
var
	i: Integer;
begin
	Result := Copy(aData, 1, BinXmlSignatureSize) = BinXmlSignature;
	if not Result then begin
		i := 1;
		while (i <= Length(aData)) and IsAnsiWhitespace(aData[i]) do begin
			Inc(i);
    end;
		Result := Copy(aData, i, Length('<?xml ')) = '<?xml ';
	end;
end;




function XmlIsInBinaryFormat(const aData: RawByteString): Boolean;
begin
	Result := Copy(aData, 1, BinXmlSignatureSize) = BinXmlSignature
end;




var
	Base64Map: array [0..63] of Char = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

type
	PChars = ^TChars;
	TChars = packed record a, b, c, d: Char end;
	POctet = ^TOctet;
	TOctet = packed record a, b, c: Byte; end;

procedure OctetToChars(po: POctet; aCount: Integer; pc: PChars);
var
	o: Integer;
begin
	if aCount = 1 then begin
		o := po.a shl 16;
		pc.a := Base64Map[(o shr 18) and $3F];
		pc.b := Base64Map[(o shr 12) and $3F];
    pc.c := '=';
    pc.d := '=';
	end
	else if aCount = 2 then begin
		o := po.a shl 16 or po.b shl 8;
		pc.a := Base64Map[(o shr 18) and $3F];
		pc.b := Base64Map[(o shr 12) and $3F];
		pc.c := Base64Map[(o shr 6) and $3F];
    pc.d := '=';
	end
	else if aCount > 2 then begin
		o := po.a shl 16 or po.b shl 8 or po.c;
		pc.a := Base64Map[(o shr 18) and $3F];
		pc.b := Base64Map[(o shr 12) and $3F];
		pc.c := Base64Map[(o shr 6) and $3F];
		pc.d := Base64Map[o and $3F];
	end;
end;

function BinToBase64(const aBin; aSize, aMaxLineLength: Integer): String;
var
	o: POctet;
	c: PChars;
	aCount: Integer;
	i: Integer;
begin
	o := @aBin;
	aCount := aSize;
	SetLength(Result, ((aCount + 2) div 3)*4);
	c := PChars(Result);
	while aCount > 0 do begin
		OctetToChars(o, aCount, c);
		Inc(o);
		Inc(c);
		Dec(aCount, 3);
	end;
	if aMaxLineLength > 0 then begin
		i := aMaxLineLength;
		while i <= Length(Result) do begin
			Insert(#13#10, Result, i);
			Inc(i, 2 + aMaxLineLength);
		end
	end;
end;

function CharTo6Bit(c: Char): Byte;
begin
	if (c >= 'A') and (c <= 'Z') then begin
		Result := Ord(c) - Ord('A')
  end
	else if (c >= 'a') and (c <= 'z') then begin
		Result := Ord(c) - Ord('a') + 26
  end
	else if (c >= '0') and (c <= '9') then begin
		Result := Ord(c) - Ord('0') + 52
  end
	else if c = '+' then begin
		Result := 62
  end
	else if c = '/' then begin
		Result := 63
  end
	else begin
		Result := 0
  end
end;

procedure CharsToOctet(c: PChars; o: POctet);
var
	i: Integer;
begin
	if c.c = '=' then begin // 1 byte
		i := CharTo6Bit(c.a) shl 18 or CharTo6Bit(c.b) shl 12;
		o.a := (i shr 16) and $FF;
	end
	else if c.d = '=' then begin // 2 bytes
		i := CharTo6Bit(c.a) shl 18 or CharTo6Bit(c.b) shl 12 or CharTo6Bit(c.c) shl 6;
		o.a := (i shr 16) and $FF;
		o.b := (i shr 8) and $FF;
	end
	else begin // 3 bytes
		i := CharTo6Bit(c.a) shl 18 or CharTo6Bit(c.b) shl 12 or CharTo6Bit(c.c) shl 6 or CharTo6Bit(c.d);
		o.a := (i shr 16) and $FF;
		o.b := (i shr 8) and $FF;
		o.c := i and $FF;
	end;
end;

function Base64ToBin(const aBase64: String): RawByteString;
var
	o: POctet;
	c: PChars;
	aCount: Integer;
	s: String;
	i, j: Integer;
begin
	s := aBase64;
	i := 1;
	while i <= Length(s) do begin
		while (i <= Length(s)) and (s[i] > ' ') do begin
			Inc(i);
    end;
		if i <= Length(s) then begin
			j := i;
			while (j <= Length(s)) and (s[j] <= ' ') do begin
				Inc(j);
      end;
			Delete(s, i, j - i);
		end;
	end;

	if Length(s) < 4 then begin
    SetLength(Result, 0)
  end
	else begin
		aCount := ((Length(s) + 3) div 4)*3;
		if aCount > 0 then begin
			if s[Length(s) - 1] = '=' then begin
				Dec(aCount, 2)
      end
			else if s[Length(s)] = '=' then begin
				Dec(aCount);
      end;
			SetLength(Result, aCount);
			FillChar(Result[1], aCount, 0);
			c := @s[1];
			o := @Result[1];
			while aCount > 0 do begin
				CharsToOctet(c, o);
				Inc(o);
				Inc(c);
				Dec(aCount, 3);
			end;
		end;
	end;
end;


type
	TBinaryXmlReader = class
	private
		FOptions: LongWord;
	public
		procedure Read(var aBuf; aSize: Integer); virtual; abstract;

		function ReadLongint: Longint;
		function ReadAnsiString: AnsiString;
		function ReadUnicodeString: UnicodeString;
		function ReadXmlString: String;
		procedure ReadVariant(var v: TVarData);
	end;

	TStreamBinaryXmlReader = class(TBinaryXmlReader)
	private
		FStream: TStream;
		FOptions: LongWord;
		FBufStart,
		FBufEnd,
		FBufPtr: PByte;
		FBufSize,
		FRestSize: Integer;
	public
		constructor Create(aStream: TStream; aBufSize: Integer);
		destructor Destroy; override;

		procedure Read(var aBuf; aSize: Integer); override;
	end;

	TRawByteStringBinaryXmlReader = class(TBinaryXmlReader)
	private
		FString: RawByteString;
		FOptions: LongWord;
		FPtr: PByte;
		FRestSize: Integer;
	public
		constructor Create(const aStr: RawByteString);

		procedure Read(var aBuf; aSize: Integer); override;
	end;

	TBinaryXmlWriter = class
	private
		FOptions: LongWord;
	public
		procedure Write(const aBuf; aSize: Integer); virtual; abstract;

		procedure WriteLongint(aValue: Longint);
		procedure WriteAnsiString(const aValue: AnsiString);
		procedure WriteUnicodeString(const aValue: UnicodeString);
		procedure WriteXmlString(const aValue: String);
		procedure WriteVariant(const v: TVarData);
	end;

	TStreamBinrayXmlWriter = class(TBinaryXmlWriter)
	private
		FStream: TStream;
		FBufStart,
		FBufEnd,
		FBufPtr: PAnsiChar;
		FBufSize: Integer;
	public
		constructor Create(aStream: TStream; anOptions: LongWord; aBufSize: Integer);
		destructor Destroy; override;

		procedure Write(const aBuf; aSize: Integer); override;
	end;

	TRawByteStringBinaryXmlWriter = class(TBinaryXmlWriter)
	private
		FData: RawByteString;
		FBufStart,
		FBufEnd,
		FBufPtr: PAnsiChar;
		FBufSize: Integer;
    procedure FlushBuf;
	public
		constructor Create(anOptions: LongWord; aBufSize: Integer);
		destructor Destroy; override;

		procedure Write(const aBuf; aSize: Integer); override;
	end;

	TXmlBase = class(TInterfacedObject, IXmlBase)
	protected
		// реализация интерфейса IXmlBase
		function GetObject: TObject;
	public
	end;

	PNameIndexArray = ^TNameIndexArray;
	TNameIndexArray = array of Longint;
	TXmlNameTable = class(TXmlBase, IXmlNameTable)
	private
		FNames: array of String;
		FHashTable: array of TNameIndexArray;

		FXmlTextNameID: Integer;
		FXmlCDATASectionNameID: Integer;
		FXmlCommentNameID: Integer;
		FXmlDocumentNameID: Integer;
		FXmlID: Integer;
	protected
		function GetID(const aName: String): Integer;
		function GetName(anID: Integer): String;
	public
		constructor Create(aHashTableSize: Integer);

		procedure LoadBinXml(aReader: TBinaryXmlReader);
		procedure SaveBinXml(aWriter: TBinaryXmlWriter);
	end;

{ TXmlBase }

function TXmlBase.GetObject: TObject;
begin
	Result := Self;
end;

{ TXmlNameTable }

constructor TXmlNameTable.Create(aHashTableSize: Integer);
begin
	inherited Create;
	SetLength(FHashTable, aHashTableSize);
	FXmlTextNameID := GetID('#text');
	FXmlCDATASectionNameID := GetID('#cdata-section');
	FXmlCommentNameID := GetID('#comment');
	FXmlDocumentNameID := GetID('#document');
	FXmlID := GetID('xml');
end;

procedure TXmlNameTable.LoadBinXml(aReader: TBinaryXmlReader);
var
	aCount: LongInt;
	anIndex, i: Integer;
begin
	// Считать массив имен
	aCount := aReader.ReadLongint;
	SetLength(FNames, aCount);
	for i := 0 to aCount - 1 do begin
		FNames[i] := aReader.ReadXmlString;
  end;

	// Считать хэш-таблицу
	SetLength(FHashTable, aReader.ReadLongint);
	for i := 0 to Length(FHashTable) - 1 do begin
		SetLength(FHashTable[i], 0);
  end;
	aCount := aReader.ReadLongint;
	for i := 0 to aCount - 1 do begin
		anIndex := aReader.ReadLongInt;
		SetLength(FHashTable[anIndex], aReader.ReadLongInt);
		aReader.Read(FHashTable[anIndex][0], Length(FHashTable[anIndex])*sizeof(Longint));
	end;
end;

procedure TXmlNameTable.SaveBinXml(aWriter: TBinaryXmlWriter);
var
	aCount: LongInt;
	i: Integer;
begin
	// Записать массив имен
	aCount := Length(FNames);
	aWriter.WriteLongint(aCount);
	for i := 0 to aCount - 1 do begin
		aWriter.WriteXmlString(FNames[i]);
  end;

	// Записать хэш-таблицу
	aWriter.WriteLongint(Length(FHashTable));
	aCount := 0;
	for i := 0 to Length(FHashTable) - 1 do begin
		if Length(FHashTable[i]) > 0 then begin
			Inc(aCount);
    end
  end;
	aWriter.WriteLongint(aCount);
	for i := 0 to Length(FHashTable) - 1 do begin
		aCount := Length(FHashTable[i]);
		if aCount > 0 then begin
			aWriter.WriteLongint(i);
			aWriter.WriteLongint(aCount);
			aWriter.Write(FHashTable[i][0], aCount*sizeof(Longint));
		end
	end;
end;

function TXmlNameTable.GetID(const aName: String): Integer;

	function NameHashKey(const aName: String): UINT;
	var
		i: Integer;
	begin
		Result := 0;
		for i := 1 to Length(aName) do begin
			Result := UINT((int64(Result) shl 5) + Result + Ord(aName[i]));
    end;
	end;
	
var
	i: Integer;
	aNameIndexes: PNameIndexArray;
begin
	if aName = '' then begin
		Result := -1
  end
	else begin
		aNameIndexes := @FHashTable[NameHashKey(aName) mod UINT(Length(FHashTable))];
		for i := 0 to Length(aNameIndexes^) - 1 do begin
			Result := aNameIndexes^[i];
			if FNames[Result] = aName then begin
				Exit
      end;
		end;
		Result := Length(FNames);
		SetLength(FNames, Result + 1);
		FNames[Result] := aName;

		SetLength(aNameIndexes^, Length(aNameIndexes^) + 1);
		aNameIndexes^[Length(aNameIndexes^) - 1] := Result;
	end;
end;

function TXmlNameTable.GetName(anID: Integer): String;
begin
	if anID < 0 then begin
		Result := ''
  end
	else begin
		Result := FNames[anID]
  end
end;

function CreateNameTable(aHashTableSize: Integer): IXmlNameTable;
begin
	Result := TXmlNameTable.Create(aHashTableSize)
end;

type
	TXmlNode = class;
	TXmlToken = class
	private
		FValueBuf: String;
		FValueStart,
		FValuePtr,
		FValueEnd: PChar;
	public
		constructor Create;
		procedure Clear;
		procedure AppendChar(aChar: Char);
		procedure AppendText(aText: PChar; aCount: Integer);
		function Length: Integer;

		property ValueStart: PChar read FValueStart;
	end;

	TXmlSource = class
	private
		FPrevChar: Char;
		FCurLine, FCurPos: Integer;
		FTokenStack: array of TXmlToken;
		FTokenStackTop: Integer;
		FToken: TXmlToken;
		function ExpectQuotedText(aQuote: Char): String;
	public
		CurChar: Char;
		constructor Create;
		destructor Destroy; override;

		function EOF: Boolean; virtual; abstract;
		function DoNext: Boolean; virtual; abstract;
		function Next: Boolean;

		procedure SkipBlanks;
		function ExpectXmlName: String;
		function ExpectXmlEntity: Char;
		procedure ExpectChar(aChar: Char);
		procedure ExpectText(aText: PChar);
		function ExpectDecimalInteger: Integer;
		function ExpectHexInteger: Integer;
		function ParseTo(aText: PChar): String;
		procedure ParseAttrs(aNode: TXmlNode);

		procedure NewToken;
		procedure AppendTokenChar(aChar: Char);
		procedure AppendTokenText(aText: PChar; aCount: Integer);
		function AcceptToken: String;
		procedure DropToken;
	end;

	TStringXmlSource = class(TXmlSource)
	private
		FSource: String;
		FSourcePtr,
		FSourceEnd: PChar;
	public
		constructor Create(const aSource: String);
		function EOF: Boolean; override;
		function DoNext: Boolean; override;
	end;

	TAnsiStreamXmlSource = class(TXmlSource)
	private
		FStream: TStream;
		FBufStart,
		FBufPtr,
		FBufEnd: PAnsiChar;

		FBufSize: Integer;
		FSize: Integer;
	public
		constructor Create(aStream: TStream; aBufSize: Integer);
		function EOF: Boolean; override;
		function DoNext: Boolean; override;
    destructor Destroy; override;
	end;

	TXmlNodeList = class(TXmlBase, IXmlNodeList)
	private
		FOwnerNode: TXmlNode;

		FItems: array of TXmlNode;
		FCount: Integer;
		procedure Grow;
	protected
		function Get_Count: Integer;
		function Get_Item(anIndex: Integer): IXmlNode;
		function Get_XML: String;
    procedure GetXML(var anXml: TStringBuilder);
	public
		constructor Create(anOwnerNode: TXmlNode);
		destructor Destroy; override;

		function IndexOfNode(aNode: TXmlNode): Integer;
		procedure ParseXML(anXml: TXmlSource; aNames: TXmlNameTable; aPreserveWhiteSpace: Boolean);

		procedure SortElements(aCompare: TXmlCompareNodes);
		procedure LoadBinXml(aReader: TBinaryXmlReader; aCount: Integer; aNames: TXmlNameTable);
		procedure SaveBinXml(aWriter: TBinaryXmlWriter);

		procedure InsertNode(aNode: TXmlNode; anIndex: Integer);
		function RemoveNode(aNode: TXmlNode): Integer;
		procedure DeleteNode(anIndex: Integer);
		procedure ReplaceNode(anIndex: Integer; aNode: TXmlNode);
		procedure ClearNodes;

		function IndexOf(const aNode: IXmlNode): Integer;
		procedure Insert(const aNode: IXmlNode; anIndex: Integer);
		function Remove(const aNode: IXmlNode): Integer;
		procedure Delete(anIndex: Integer);
		procedure Clear;
    procedure Add(const aNode: IXmlNode);

	end;

	PXmlAttrData = ^TXmlAttrData;
	TXmlAttrData = record
		NameID: Integer;
		Value: Variant;
	end;

	TXmlDocument = class;
	TXmlNode = class(TXmlBase, IXmlNode)
	private
		FSourceLine, FSourceCol: Integer;

		FParentNode: TXmlNode;
		// FNames - таблица имен. Задается извне
		FNames: TXmlNameTable;
		// Количество атрибутов в массиве FAttrs
		FAttrCount: Integer;
		// Массив атрибутов
		FAttrs: array of TXmlAttrData;
		// Список дочерних узлов
		FChilds: TXmlNodeList;
		function GetChilds: TXmlNodeList; virtual;
		function FindFirstChild(aNameID: Integer): TXmlNode;
		procedure GetAttrsXML(var anXml: TStringBuilder);
		function FindAttrData(aNameID: Integer): PXmlAttrData;
		function GetOwnerDocument: TXmlDocument;
		procedure SetNameTable(aValue: TXmlNameTable; aMap: TList);
		procedure SetNodeNameID(aValue: Integer); virtual;
		function DoCloneNode(aDeep: Boolean): IXmlNode; virtual; abstract;

	protected
		// IXmlNode
		function Get_SourceLine: Integer;
		function Get_SourceCol: Integer;

		function Get_NameTable: IXmlNameTable;
		function Get_NodeName: String;

		function Get_NodeNameID: Integer; virtual; abstract;
		function Get_NodeType: Integer; virtual; abstract;
		function Get_Text: String; virtual; abstract;
		procedure Set_Text(const aValue: String); virtual; abstract;
		function CloneNode(aDeep: Boolean): IXmlNode;

		procedure LoadBinXml(aReader: TBinaryXmlReader);
		procedure SaveBinXml(aWriter: TBinaryXmlWriter);

		function Get_DataType: Integer; virtual;
		function Get_TypedValue: Variant; virtual;
		procedure Set_TypedValue(const aValue: Variant); virtual;

		procedure GetXML(var anXml: TStringBuilder); virtual; abstract;
		function Get_XML: String; virtual;

		function Get_OwnerDocument: IXmlDocument; virtual;
		function Get_ParentNode: IXmlNode;
		function Get_NextSibling: IXmlNode;

		function Get_ChildNodes: IXmlNodeList; virtual;
		procedure AppendChild(const aChild: IXmlNode);

		function AppendElement(aNameID: Integer): IXmlElement; overload;
		function AppendElement(const aName: String): IXmlElement; overload;
		function AppendText(const aData: String): IXmlText;
		function AppendCDATA(const aData: String): IXmlCDATASection;
		function AppendComment(const aData: String): IXmlComment;
		function AppendProcessingInstruction(aTargetID: Integer;
			const aData: String): IXmlProcessingInstruction; overload;
		function AppendProcessingInstruction(const aTarget: String;
			const aData: String): IXmlProcessingInstruction; overload;

		procedure InsertBefore(const aChild, aBefore: IXmlNode);
		procedure ReplaceChild(const aNewChild, anOldChild: IXmlNode);
		procedure RemoveChild(const aChild: IXmlNode);
		function GetChildText(const aName: String; const aDefault: String = ''): String; overload;
		function GetChildText(aNameID: Integer; const aDefault: String = ''): String; overload;
		procedure SetChildText(const aName, aValue: String); overload;
		procedure SetChildText(aNameID: Integer; const aValue: String); overload;

		function NeedChild(aNameID: Integer): IXmlNode; overload;
		function NeedChild(const aName: String): IXmlNode; overload;
		function EnsureChild(aNameID: Integer): IXmlNode; overload;
		function EnsureChild(const aName: String): IXmlNode; overload;

		procedure RemoveAllChilds;

		function SelectNodes(const anExpression: String): IXmlNodeList; overload;
		function SelectNodes(aNodeNameID: Integer): IXmlNodeList; overload;

		function SelectSingleNode(const anExpression: String): IXmlNode;
		function FindElement(const anElementName, anAttrName: String; const anAttrValue: Variant): IXmlElement;
		function FindElements(const anElementName, anAttrName: String; const anAttrValue: Variant): IXmlNodeList;

		function Get_AttrCount: Integer;
		function Get_AttrNameID(anIndex: Integer): Integer;
		function Get_AttrName(anIndex: Integer): String;
		procedure RemoveAttr(const aName: String); overload;
		procedure RemoveAttr(aNameID: Integer); overload;
		procedure RemoveAllAttrs;

		function AttrExists(aNameID: Integer): Boolean; overload;
		function AttrExists(const aName: String): Boolean; overload;

		function GetAttrType(aNameID: Integer): Integer; overload;
		function GetAttrType(const aName: String): Integer; overload;

		function GetVarAttr(aNameID: Integer; const aDefault: Variant): Variant; overload;
		function GetVarAttr(const aName: String; const aDefault: Variant): Variant; overload;
		procedure SetVarAttr(aNameID: Integer; const aValue: Variant); overload;
		procedure SetVarAttr(const aName: String; aValue: Variant); overload;

		function NeedVarAttr(aNameID: Integer): Variant; overload;
		function NeedVarAttr(const aName: String): Variant; overload;

		function NeedAttr(aNameID: Integer): String; overload;
		function NeedAttr(const aName: String): String; overload;

		function GetAttr(aNameID: Integer; const aDefault: String = ''): String; overload;
		function GetAttr(const aName: String; const aDefault: String = ''): String; overload;
		procedure SetAttr(aNameID: Integer; const aValue: String); overload;
		procedure SetAttr(const aName, aValue: String); overload;

		function GetBoolAttr(aNameID: Integer; aDefault: Boolean = False): Boolean; overload;
		function GetBoolAttr(const aName: String; aDefault: Boolean = False): Boolean; overload;
		procedure SetBoolAttr(aNameID: Integer; aValue: Boolean = False); overload;
		procedure SetBoolAttr(const aName: String; aValue: Boolean); overload;

		function GetIntAttr(aNameID: Integer; aDefault: Integer = 0): Integer; overload;
		function GetIntAttr(const aName: String; aDefault: Integer = 0): Integer; overload;
    function NeedIntAttr(const aName: String): Integer; overload;
    function NeedIntAttr(aNameID: Integer): Integer; overload;

		procedure SetIntAttr(aNameID: Integer; aValue: Integer); overload;
		procedure SetIntAttr(const aName: String; aValue: Integer); overload;

		function GetDateTimeAttr(aNameID: Integer; aDefault: TDateTime = 0): TDateTime; overload;
		function GetDateTimeAttr(const aName: String; aDefault: TDateTime = 0): TDateTime; overload;
		procedure SetDateTimeAttr(aNameID: Integer; aValue: TDateTime); overload;
		procedure SetDateTimeAttr(const aName: String; aValue: TDateTime); overload;

		function GetFloatAttr(aNameID: Integer; aDefault: Double = 0): Double; overload;
		function GetFloatAttr(const aName: String; aDefault: Double = 0): Double; overload;
		function NeedFloatAttr(aNameID: Integer): Double; overload;
		function NeedFloatAttr(const aName: String): Double; overload;
		procedure SetFloatAttr(aNameID: Integer; aValue: Double); overload;
		procedure SetFloatAttr(const aName: String; aValue: Double); overload;

		function GetHexAttr(const aName: String; aDefault: Integer = 0): Integer; overload;
		function GetHexAttr(aNameID: Integer; aDefault: Integer = 0): Integer; overload;
		procedure SetHexAttr(const aName: String; aValue: Integer; aDigits: Integer = 8); overload;
		procedure SetHexAttr(aNameID: Integer; aValue: Integer; aDigits: Integer = 8); overload;

		function GetEnumAttr(const aName: String;
			const aValues: array of String; aDefault: Integer = 0): Integer; overload;
		function GetEnumAttr(aNameID: Integer;
			const aValues: array of String; aDefault: Integer = 0): Integer; overload;
		function NeedEnumAttr(const aName: String;
			const aValues: array of String): Integer; overload;
		function NeedEnumAttr(aNameID: Integer;
			const aValues: array of String): Integer; overload;

		procedure RemoveTextNodes;
		procedure ReplaceTextByCDATASection(const aText: String);
		procedure ReplaceTextByBinaryData(const aData; aSize: Integer;
			aMaxLineLength: Integer);
		function GetTextAsBinaryData: RawByteString;
		function GetOwnText: String;

		function Get_Values(const aName: String): Variant;
		procedure Set_Values(const aName: String; const aValue: Variant);

		function AsElement: IXmlElement; virtual;
		function AsText: IXmlText; virtual;
		function AsCDATASection: IXmlCDATASection; virtual;
		function AsComment: IXmlComment; virtual;
		function AsProcessingInstruction: IXmlProcessingInstruction; virtual;

	public
		constructor Create(aNames: TXmlNameTable);
		destructor Destroy; override;
	end;

	TXmlElement = class(TXmlNode, IXmlElement)
	private
		FNameID: Integer;
		FData: Variant;
		procedure SetNodeNameID(aValue: Integer); override;
		function DoCloneNode(aDeep: Boolean): IXmlNode; override;
	protected
		function GetChilds: TXmlNodeList; override;

		function Get_NodeNameID: Integer; override;
		function Get_NodeType: Integer; override;
		function Get_Text: String; override;
		procedure Set_Text(const aValue: String); override;
		function Get_DataType: Integer; override;
		function Get_TypedValue: Variant; override;
		procedure Set_TypedValue(const aValue: Variant); override;
		procedure GetXML(var anXml: TStringBuilder); override;
		function AsElement: IXmlElement; override;
		function Get_ChildNodes: IXmlNodeList; override;

	public
		constructor Create(aNames: TXmlNameTable; aNameID: Integer);
	end;

	TXmlCharacterData = class(TXmlNode, IXmlCharacterData)
	private
		FData: String;
	protected
		function Get_Text: String; override;
		procedure Set_Text(const aValue: String); override;
	public
		constructor Create(aNames: TXmlNameTable; const aData: String);
	end;

	TXmlText = class(TXmlNode, IXmlText)
	private
		FData: Variant;
		function DoCloneNode(aDeep: Boolean): IXmlNode; override;
	protected
		function Get_NodeNameID: Integer; override;
		function Get_NodeType: Integer; override;
		function Get_Text: String; override;
		procedure Set_Text(const aValue: String); override;
		function Get_DataType: Integer; override;
		function Get_TypedValue: Variant; override;
		procedure Set_TypedValue(const aValue: Variant); override;
    procedure GetXML(var anXml: TStringBuilder); override;
		function AsText: IXmlText; override;
	public
		constructor Create(aNames: TXmlNameTable; const aData: Variant);
	end;

	TXmlCDATASection = class(TXmlCharacterData, IXmlCDATASection)
	protected
		function Get_NodeNameID: Integer; override;
		function Get_NodeType: Integer; override;
    procedure GetXML(var anXml: TStringBuilder); override;
		function AsCDATASection: IXmlCDATASection; override;
		function DoCloneNode(aDeep: Boolean): IXmlNode; override;
	public
	end;

	TXmlComment = class(TXmlCharacterData, IXmlComment)
	protected
		function Get_NodeNameID: Integer; override;
		function Get_NodeType: Integer; override;
    procedure GetXML(var anXml: TStringBuilder); override;
		function AsComment: IXmlComment; override;
		function DoCloneNode(aDeep: Boolean): IXmlNode; override;
	public
	end;

	TXmlProcessingInstruction = class(TXmlNode, IXmlProcessingInstruction)
	private
		FTargetID: Integer;
		FData: String;
		procedure SetNodeNameID(aValue: Integer); override;
		function DoCloneNode(aDeep: Boolean): IXmlNode; override;
	protected
		function Get_NodeNameID: Integer; override;
		function Get_NodeType: Integer; override;
		function Get_Text: String; override;
		procedure Set_Text(const aText: String); override;
		procedure GetXML(var anXml: TStringBuilder); override;
		function AsProcessingInstruction: IXmlProcessingInstruction; override;
		function Get_Target: String;

	public
		constructor Create(aNames: TXmlNameTable; aTargetID: Integer;
			const aData: String);
	end;

	TXmlDocument = class(TXmlNode, IXmlDocument)
	private
		FPreserveWhiteSpace: Boolean;

		function DoCloneNode(aDeep: Boolean): IXmlNode; override;
	protected
		function Get_NodeNameID: Integer; override;
		function Get_NodeType: Integer; override;
		function Get_Text: String; override;
		procedure Set_Text(const aText: String); override;
    procedure GetXML(var anXml: TStringBuilder); override;
		function Get_PreserveWhiteSpace: Boolean;
		procedure Set_PreserveWhiteSpace(aValue: Boolean);

		function NewDocument(const aVersion, anEncoding: String;
			aRootElementNameID: Integer): IXmlElement; overload;
		function NewDocument(const aVersion, anEncoding,
			aRootElementName: String): IXmlElement; overload;

		function CreateElement(aNameID: Integer): IXmlElement; overload;
		function CreateElement(const aName: String): IXmlElement; overload;
		function CreateText(const aData: String): IXmlText;
		function CreateCDATASection(const aData: String): IXmlCDATASection;
		function CreateComment(const aData: String): IXmlComment;
		function Get_DocumentElement: IXmlElement;
		function CreateProcessingInstruction(const aTarget,
			aData: String): IXmlProcessingInstruction; overload;
		function CreateProcessingInstruction(aTargetID: Integer;
			const aData: String): IXmlProcessingInstruction; overload;
		procedure LoadXML(const anXml: String); overload;
    {$if CompilerVersion >= 20}
		procedure LoadXML(const anXml: RawByteString); overload;
    {$ifend}

		procedure Load(aStream: TStream); overload;
		procedure Load(const aFileName: String); overload;

		procedure LoadResource(aType, aName: PChar);
		 
		procedure Save(aStream: TStream); overload;
		procedure Save(const aFileName: String); overload;

		procedure SaveBinary(aStream: TStream; anOptions: LongWord); overload;
		procedure SaveBinary(const aFileName: String; anOptions: LongWord); overload;

		function Get_BinaryXML: RawByteString;
		procedure LoadBinaryXML(const anXml: RawByteString);
	public
		constructor Create(aNames: TXmlNameTable);
	end;

{ TXmlNodeList }

procedure TXmlNodeList.ClearNodes;
var
	i: Integer;
	aNode: TXmlNode;
begin
	for i := 0 to FCount - 1 do begin
		aNode := FItems[i];
		if Assigned(FOwnerNode) then begin
			aNode.FParentNode := nil;
    end;
		aNode._Release;
	end;
	FCount := 0;
end;

procedure TXmlNodeList.DeleteNode(anIndex: Integer);
var
	aNode: TXmlNode;
begin
	aNode := FItems[anIndex];
	Dec(FCount);
	if anIndex < FCount then begin
		Move(FItems[anIndex + 1], FItems[anIndex], (FCount - anIndex)*SizeOf(TXmlNode));
  end;
	if Assigned(aNode) then begin
		if Assigned(FOwnerNode) then begin
			aNode.FParentNode := nil;
    end;
		aNode._Release;
	end;
end;

constructor TXmlNodeList.Create(anOwnerNode: TXmlNode);
begin
	inherited Create;
	FOwnerNode := anOwnerNode;
end;

destructor TXmlNodeList.Destroy;
begin
	ClearNodes;
	inherited;
end;

function TXmlNodeList.Get_Item(anIndex: Integer): IXmlNode;
begin
	if (anIndex < 0) or (anIndex >= FCount) then begin
		raise Exception.Create(SSimpleXmlError1);
  end;
	Result := FItems[anIndex]
end;

function TXmlNodeList.Get_Count: Integer;
begin
	Result := FCount
end;

function TXmlNodeList.IndexOfNode(aNode: TXmlNode): Integer;
var
	i: Integer;
begin
	for i := 0 to FCount - 1 do begin
		if FItems[i] = aNode then begin
			Result := i;
			Exit
		end;
  end;
	Result := -1;
end;

procedure TXmlNodeList.Grow;
var
	aDelta: Integer;
begin
	if Length(FItems) > 64 then begin
		aDelta := Length(FItems) div 4
  end
	else begin
		if Length(FItems) > 8 then begin
			aDelta := 16
    end
		else begin
			aDelta := 4;
    end
  end;
	SetLength(FItems, Length(FItems) + aDelta);
end;

procedure TXmlNodeList.InsertNode(aNode: TXmlNode; anIndex: Integer);
begin
	if anIndex = -1 then begin
		anIndex := FCount;
  end;
	if FCount = Length(FItems) then begin
		Grow;
  end;
	if anIndex < FCount then begin
		Move(FItems[anIndex], FItems[anIndex + 1], (FCount - anIndex)*SizeOf(TXmlNode));
  end;
	FItems[anIndex] := aNode;
	Inc(FCount);
	if aNode <> nil then begin
		aNode._AddRef;
		if Assigned(FOwnerNode) then begin
			aNode.FParentNode := FOwnerNode;
			aNode.SetNameTable(FOwnerNode.FNames, nil);
		end;
	end;
end;

function TXmlNodeList.RemoveNode(aNode: TXmlNode): Integer;
begin
	Result := IndexOfNode(aNode);
	if Result <> -1 then begin
		DeleteNode(Result);
  end;
end;

procedure TXmlNodeList.ReplaceNode(anIndex: Integer; aNode: TXmlNode);
var
	anOldNode: TXmlNode;
begin
	anOldNode := FItems[anIndex];
	if aNode = anOldNode then begin
    exit
  end;
  if Assigned(anOldNode) then begin
    if Assigned(FOwnerNode) then begin
      anOldNode.FParentNode := nil;
    end;
    anOldNode._Release;
  end;
  FItems[anIndex] := aNode;
  if Assigned(aNode) then begin
    aNode._AddRef;
    if Assigned(FOwnerNode) then begin
      aNode.FParentNode := FOwnerNode;
      aNode.SetNameTable(FOwnerNode.FNames, nil);
    end
  end
end;

function TXmlNodeList.Get_XML: String;
var
  anXml: TStringBuilder;
begin
  anXml.Init;
  GetXML(anXml);
  anXml.GetString(Result);
end;

procedure TXmlNodeList.GetXML(var anXml: TStringBuilder);
var
	i: Integer;
begin
	for i := 0 to FCount - 1 do begin
		FItems[i].GetXML(anXml);
  end;
end;

procedure TXmlNodeList.ParseXML(anXml: TXmlSource; aNames: TXmlNameTable; aPreserveWhiteSpace: Boolean);
var
	aLine, aCol: Integer;

	procedure DoAppend(aNode: TXmlNode);
	begin
		aNode.FSourceLine := aLine;
		aNode.FSourceCol := aCol;
		InsertNode(aNode, -1);
	end;

	// на входе: символ текста
	// на выходе: символ разметки '<'
	procedure ParseText;
	var
		aText: String;
	begin
		anXml.NewToken;
		while not anXml.EOF and (anXml.CurChar <> '<') do begin
			if anXml.CurChar = '&' then begin
				anXml.AppendTokenChar(anXml.ExpectXmlEntity)
      end
			else begin
				anXml.AppendTokenChar(anXml.CurChar);
				anXml.Next;
			end;
    end;
		aText := anXml.AcceptToken;
		if aPreserveWhiteSpace or (Trim(aText) <> '') then begin
			DoAppend(TXmlText.Create(aNames, aText));
    end;
	end;

	// CurChar - '?'
	procedure ParseProcessingInstruction;
	var
		aTarget: String;
		aNode: TXmlProcessingInstruction;
	begin
		anXml.Next;
		aTarget := anXml.ExpectXmlName;
		aNode := TXmlProcessingInstruction.Create(aNames, aNames.GetID(aTarget), '');
		DoAppend(aNode);
		if aNode.FTargetID = aNames.FXmlID then begin
			anXml.ParseAttrs(aNode);
			anXml.ExpectText('?>');
		end
		else begin
			aNode.FData := anXml.ParseTo('?>');
    end
	end;

	// на входе: первый '--'
	// на выходе: символ после '-->'
	procedure ParseComment;
	begin
		anXml.ExpectText('--');
		DoAppend(TXmlComment.Create(aNames, anXml.ParseTo('-->')));
	end;

	// на входе: '[CDATA['
	// на выходе: символ после ']]>'
	procedure ParseCDATA;
	begin
		anXml.ExpectText('[CDATA[');
		DoAppend(TXmlCDATASection.Create(aNames, anXml.ParseTo(']]>')));
	end;


	// на входе: 'DOCTYPE'
	// на выходе: символ после '>'
	procedure ParseDOCTYPE;
	begin
		anXml.ExpectText('DOCTYPE');
		anXml.ParseTo('>');
	end;

	// на входе: 'имя-элемента'
	// на выходе: символ после '>'
	procedure ParseElement;
	var
		aNameID: Integer;
		aNode: TXmlElement;
	begin
		aNameID := aNames.GetID(anXml.ExpectXmlName);
		if anXml.EOF then begin
			raise Exception.Create(SSimpleXMLError2);
    end;
		if not ((anXml.CurChar <= ' ') or (anXml.CurChar = '/') or (anXml.CurChar = '>')) then begin
			raise Exception.Create(SSimpleXMLError3);
    end;
		aNode := TXmlElement.Create(aNames, aNameID);
		DoAppend(aNode);
		anXml.ParseAttrs(aNode);
		if anXml.CurChar = '/' then begin
			anXml.ExpectText('/>')
    end
		else begin
			anXml.ExpectChar('>');
			aNode.GetChilds.ParseXML(anXml, aNames, aPreserveWhiteSpace);
			anXml.ExpectChar('/');
			anXml.ExpectText(PChar(aNames.GetName(aNameID)));
			anXml.SkipBlanks;
			anXml.ExpectChar('>');
		end;
	end;
	
begin
	while not anXml.EOF do begin
		aLine := anXml.FCurLine;
		aCol := anXml.FCurPos;
		ParseText;
		aLine := anXml.FCurLine;
		aCol := anXml.FCurPos;
		if anXml.CurChar = '<' then begin // символ разметки
			if anXml.Next then begin
				if anXml.CurChar = '/' then begin // закрывающий тэг элемента
					Exit
        end
				else if anXml.CurChar = '?' then begin // инструкция
					ParseProcessingInstruction
        end
				else if anXml.CurChar = '!' then begin
					if anXml.Next then begin
						if anXml.CurChar = '-' then begin // коментарий
							ParseComment
            end
						else if anXml.CurChar = '[' then begin // секция CDATA
							ParseCDATA
            end
						else begin
							ParseDOCTYPE
            end
          end
				end
				else begin // открывающий тэг элемента
					ParseElement
        end
      end
    end
	end;
end;

procedure TXmlNodeList.LoadBinXml(aReader: TBinaryXmlReader;
	aCount: Integer; aNames: TXmlNameTable);
var
	i: Integer;
	aNodeType: Byte;
	aNode: TXmlNode;
	aNameID: LongInt;
begin
	ClearNodes;
	SetLength(FItems, aCount);
	for i := 0 to aCount - 1 do begin
		aReader.Read(aNodeType, sizeof(aNodeType));
		case aNodeType of
			NODE_ELEMENT: begin
        aNameID := aReader.ReadLongint;
        aNode := TXmlElement.Create(aNames, aNameID);
        InsertNode(aNode, -1);
        aReader.ReadVariant(TVarData(TXmlElement(aNode).FData));
        aNode.LoadBinXml(aReader);
      end;
			NODE_TEXT: begin
        aNode := TXmlText.Create(aNames, Unassigned);
        InsertNode(aNode, -1);
        aReader.ReadVariant(TVarData(TXmlText(aNode).FData));
      end;
			NODE_CDATA_SECTION: begin
				InsertNode(TXmlCDATASection.Create(aNames, aReader.ReadXmlString), -1);
      end;
			NODE_PROCESSING_INSTRUCTION: begin
        aNameID := aReader.ReadLongint;
        aNode := TXmlProcessingInstruction.Create(aNames, aNameID,
          aReader.ReadXmlString);
        InsertNode(aNode, -1);
        aNode.LoadBinXml(aReader);
      end;
			NODE_COMMENT: begin
				InsertNode(TXmlComment.Create(aNames, aReader.ReadXmlString), -1);
      end
			else begin
				raise Exception.Create(SSimpleXMLError4);
      end
		end
	end;
end;

procedure TXmlNodeList.SaveBinXml(aWriter: TBinaryXmlWriter);
const
	EmptyVar: TVarData = (VType:varEmpty);
var
	aCount: LongInt;
	i: Integer;
	aNodeType: Byte;
	aNode: TXmlNode;
begin
	aCount := FCount;
	for i := 0 to aCount - 1 do begin
		aNode := FItems[i];
		aNodeType := aNode.Get_NodeType;
		aWriter.Write(aNodeType, sizeof(aNodeType));
		case aNodeType of
			NODE_ELEMENT:
				with TXmlElement(aNode) do begin
					aWriter.WriteLongint(FNameID);
					if Assigned(FChilds) and (FChilds.FCount > 0) or VarIsEmpty(FData) then
						aWriter.WriteVariant(EmptyVar)
					else
						aWriter.WriteVariant(TVarData(FData));
					SaveBinXml(aWriter);
				end;
			NODE_TEXT:
				aWriter.WriteVariant(TVarData(TXmlText(aNode).FData));
			NODE_CDATA_SECTION:
				aWriter.WriteXmlString(TXmlCDATASection(aNode).FData);
			NODE_PROCESSING_INSTRUCTION:
				begin
					aWriter.WriteLongint(TXmlProcessingInstruction(aNode).FTargetID);
					aWriter.WriteXmlString(TXmlProcessingInstruction(aNode).FData);
					aNode.SaveBinXml(aWriter);
				end;
			NODE_COMMENT:
				aWriter.WriteXmlString(TXmlComment(aNode).FData);
			else
				raise Exception.Create(SSimpleXmlError5);
		end
	end;
end;

procedure QuickSortNodes(aList: TXmlNodeList; L, R: Integer;
	aCompare: TXmlCompareNodes);
var
	I, J: Integer;
	P, T: TXmlNode;
begin
	repeat
		I := L;
		J := R;
		P := aList.FItems[(L + R) shr 1];
		repeat
			while aCompare(aList.FItems[I], P) < 0 do
				Inc(I);
			while aCompare(aList.FItems[J], P) > 0 do
				Dec(J);
			if I <= J then
			begin
				T := aList.FItems[I];
				aList.FItems[I] := aList.FItems[J];
				aList.FItems[J] := T;
				Inc(I);
				Dec(J);
			end;
		until I > J;
		if L < J then
			QuickSortNodes(aList, L, J, aCompare);
		L := I;
	until I >= R;
end;

procedure TXmlNodeList.SortElements(aCompare: TXmlCompareNodes);
begin
	if FCount > 0 then
		QuickSortNodes(Self, 0, FCount - 1, aCompare);
end;

procedure TXmlNodeList.Clear;
begin
  ClearNodes;
end;

procedure TXmlNodeList.Delete(anIndex: Integer);
begin
  DeleteNode(anIndex);
end;

function TXmlNodeList.IndexOf(const aNode: IXmlNode): Integer;
begin
  Result := IndexOfNode(aNode.GetObject as TXmlNode);
end;

procedure TXmlNodeList.Insert(const aNode: IXmlNode; anIndex: Integer);
begin
  InsertNode(aNode.GetObject as TXmlNode, anIndex);
end;

function TXmlNodeList.Remove(const aNode: IXmlNode): Integer;
begin
  Result := RemoveNode(aNode.GetObject as TXmlNode)
end;

procedure TXmlNodeList.Add(const aNode: IXmlNode);
begin
  Insert(aNode.GetObject as TXmlNode, -1);
end;

{ TXmlNode }

constructor TXmlNode.Create(aNames: TXmlNameTable);
begin
	inherited Create;
	FNames := aNames;
	FNames._AddRef;
end;

destructor TXmlNode.Destroy;
begin
	if Assigned(FChilds) then
		FChilds._Release;
	FNames._Release;
	inherited;
end;

function TXmlNode.GetChilds: TXmlNodeList;
begin
	if not Assigned(FChilds) then begin
		FChilds := TXmlNodeList.Create(Self);
		FChilds._AddRef;
	end;
	Result := FChilds;
end;

procedure TXmlNode.AppendChild(const aChild: IXmlNode);
begin
	GetChilds.InsertNode(aChild.GetObject as TXmlNode, -1);
end;

function TXmlNode.Get_AttrCount: Integer;
begin
	Result := FAttrCount;
end;

function TXmlNode.Get_AttrName(anIndex: Integer): String;
begin
	Result := FNames.GetName(FAttrs[anIndex].NameID);
end;

function TXmlNode.Get_AttrNameID(anIndex: Integer): Integer;
begin
	Result := FAttrs[anIndex].NameID;
end;

function TXmlNode.Get_ChildNodes: IXmlNodeList;
begin
	Result := GetChilds
end;

function TXmlNode.Get_NameTable: IXmlNameTable;
begin
	Result := FNames
end;

function TXmlNode.GetAttr(const aName, aDefault: String): String;
begin
	Result := GetAttr(FNames.GetID(aName), aDefault)
end;

function TXmlNode.GetAttr(aNameID: Integer;
	const aDefault: String): String;
var
	aData: PXmlAttrData;
begin
	aData := FindAttrData(aNameID);
	if Assigned(aData) then begin
		Result := aData.Value
  end
	else begin
		Result := aDefault
  end
end;

function TXmlNode.GetBoolAttr(aNameID: Integer;
	aDefault: Boolean): Boolean;
var
	aData: PXmlAttrData;
begin
	aData := FindAttrData(aNameID);
	if Assigned(aData) then
		Result := aData.Value
	else
		Result := aDefault
end;

function TXmlNode.GetBoolAttr(const aName: String;
  aDefault: Boolean): Boolean;
begin
	Result := GetBoolAttr(FNames.GetID(aName), aDefault)
end;

function TXmlNode.FindFirstChild(aNameID: Integer): TXmlNode;
var
	i: Integer;
begin
	if Assigned(FChilds) then
		for i := 0 to FChilds.FCount - 1 do begin
			Result := FChilds.FItems[i];
			if Result.Get_NodeNameID = aNameID then
				Exit
		end;
	Result := nil
end;

function TXmlNode.GetChildText(aNameID: Integer;
	const aDefault: String): String;
var
	aChild: TXmlNode;
begin
	aChild := FindFirstChild(aNameID);
	if Assigned(aChild) then
		Result := aChild.Get_Text
	else
		Result := aDefault
end;

function TXmlNode.GetChildText(const aName: String;
  const aDefault: String): String;
begin
	Result := GetChildText(FNames.GetID(aName), aDefault);
end;

function TXmlNode.GetEnumAttr(const aName: String;
	const aValues: array of String; aDefault: Integer): Integer;
begin
	Result := GetEnumAttr(FNames.GetID(aName), aValues, aDefault);
end;

function EnumAttrValue(aNode: TXmlNode; anAttrData: PXmlAttrData;
	const aValues: array of String): Integer;
var
	anAttrValue: String;
	s: String;
	i: Integer;
begin
	anAttrValue := anAttrData.Value;
	for Result := 0 to Length(aValues) - 1 do
		if CompareText(anAttrValue, aValues[Result]) = 0 then
			Exit;
	if Length(aValues) = 0 then
		s := ''
	else begin
		s := aValues[0];
		for i := 1 to Length(aValues) - 1 do begin
			s := s + ^M+^J + aValues[i];
    end
	end;
	raise Exception.CreateFmt(SSimpleXmlError6,
		[aNode.FNames.GetName(anAttrData.NameID), aNode.Get_NodeName, s]);
end;

function TXmlNode.GetEnumAttr(aNameID: Integer;
	const aValues: array of String; aDefault: Integer): Integer;
var
	anAttrData: PXmlAttrData;
begin
	anAttrData := FindAttrData(aNameID);
	if Assigned(anAttrData) then
		Result := EnumAttrValue(Self, anAttrData, aValues)
	else
		Result := aDefault;
end;

function TXmlNode.NeedEnumAttr(const aName: String;
	const aValues: array of String): Integer;
begin
	Result := NeedEnumAttr(FNames.GetID(aName), aValues)
end;

function TXmlNode.NeedEnumAttr(aNameID: Integer;
	const aValues: array of String): Integer;
var
	anAttrData: PXmlAttrData;
begin
	anAttrData := FindAttrData(aNameID);
	if Assigned(anAttrData) then
		Result := EnumAttrValue(Self, anAttrData, aValues)
	else
		raise Exception.CreateFmt(SSimpleXMLError7, [FNames.GetName(aNameID)]);
end;

function TXmlNode.GetFloatAttr(const aName: String;
	aDefault: Double): Double;
begin
	Result := GetFloatAttr(FNames.GetID(aName), aDefault);
end;

function TXmlNode.GetFloatAttr(aNameID: Integer;
	aDefault: Double): Double;
var
	aData: PXmlAttrData;
begin
	aData := FindAttrData(aNameID);
	if Assigned(aData) then
		if VarIsNumeric(aData.Value) then
			Result := aData.Value
		else
			Result := XSTRToFloat(aData.Value)
	else
		Result := aDefault
end;

function TXmlNode.NeedFloatAttr(aNameID: Integer): Double;
var
	aData: PXmlAttrData;
begin
	aData := FindAttrData(aNameID);
	if not Assigned(aData) then
		raise Exception.CreateFmt(SSimpleXmlError8, [FNames.GetName(aNameID)]);

	if VarIsNumeric(aData.Value) then
		Result := aData.Value
	else
		Result := XSTRToFloat(aData.Value)
end;

function TXmlNode.NeedFloatAttr(const aName: String): Double;
begin
	Result := NeedFloatAttr(FNames.GetID(aName));
end;

function TXmlNode.NeedIntAttr(const aName: String): Integer;
begin
  Result := NeedIntAttr(FNames.GetID(aName))
end;

function TXmlNode.NeedIntAttr(aNameID: Integer): Integer;
var
	aData: PXmlAttrData;
begin
	aData := FindAttrData(aNameID);
	if not Assigned(aData) then
		raise Exception.CreateFmt(SSimpleXmlError8, [FNames.GetName(aNameID)]);

	if VarIsOrdinal(aData.Value) then
		Result := aData.Value
	else
		Result := StrToInt(aData.Value)
end;

function TXmlNode.GetHexAttr(aNameID, aDefault: Integer): Integer;
var
	anAttr: PXmlAttrData;
begin
	anAttr := FindAttrData(aNameID);
	if Assigned(anAttr) then
		Result := StrToInt('$' + anAttr.Value)
	else
		Result := aDefault;
end;

function TXmlNode.GetHexAttr(const aName: String;
  aDefault: Integer): Integer;
begin
	Result := GetHexAttr(FNames.GetID(aName), aDefault)
end;

function TXmlNode.GetIntAttr(aNameID, aDefault: Integer): Integer;
var
	anAttr: PXmlAttrData;
begin
	anAttr := FindAttrData(aNameID);
	if Assigned(anAttr) then
		Result := anAttr.Value
	else
		Result := aDefault;
end;

function TXmlNode.GetIntAttr(const aName: String;
  aDefault: Integer): Integer;
begin
	Result := GetIntAttr(FNames.GetID(aName), aDefault)
end;

function TXmlNode.NeedVarAttr(aNameID: Integer): Variant;
var
	anAttr: PXmlAttrData;
begin
	anAttr := FindAttrData(aNameID);
	if not Assigned(anAttr) then
		raise Exception.CreateFmt(SSimpleXmlError8, [FNames.GetName(aNameID)]);
	Result := anAttr.Value
end;

function TXmlNode.NeedVarAttr(const aName: String): Variant;
begin
	Result := NeedAttr(FNames.GetID(aName))
end;

function TXmlNode.NeedAttr(aNameID: Integer): String;
var
	anAttr: PXmlAttrData;
begin
	anAttr := FindAttrData(aNameID);
	if not Assigned(anAttr) then
		raise Exception.CreateFmt(SSimpleXmlError8, [FNames.GetName(aNameID)]);
	Result := anAttr.Value
end;

function TXmlNode.NeedAttr(const aName: String): String;
begin
	Result := NeedAttr(FNames.GetID(aName))
end;

function TXmlNode.GetVarAttr(aNameID: Integer;
  const aDefault: Variant): Variant;
var
	anAttr: PXmlAttrData;
begin
	anAttr := FindAttrData(aNameID);
	if Assigned(anAttr) then
		Result := anAttr.Value
	else
		Result := aDefault;
end;

function TXmlNode.GetVarAttr(const aName: String;
  const aDefault: Variant): Variant;
begin
	Result := GetVarAttr(FNames.GetID(aName), aDefault)
end;

function TXmlNode.Get_NodeName: String;
begin
	Result := FNames.GetName(Get_NodeNameID);
end;

function TXmlNode.GetOwnerDocument: TXmlDocument;
var
	aResult: TXmlNode;
begin
	aResult := Self;
	repeat
		if aResult is TXmlDocument then
			break
		else
			aResult := aResult.FParentNode;
	until not Assigned(aResult);
	Result := TXmlDocument(aResult)
end;

function TXmlNode.Get_OwnerDocument: IXmlDocument;
var
	aDoc: TXmlDocument;
begin
	aDoc := GetOwnerDocument;
	if Assigned(aDoc) then
		Result := aDoc
	else
		Result := nil;
end;

function TXmlNode.Get_ParentNode: IXmlNode;
begin
	Result := FParentNode
end;

function TXmlNode.Get_NextSibling: IXmlNode;
var
  anIndex: Integer;
begin
  if Assigned(FParentNode) then begin
    anIndex := FParentNode.GetChilds.IndexOfNode(Self);
    if (anIndex >= 0) and (anIndex < FParentNode.FChilds.FCount - 1) then begin
      Result := FParentNode.FChilds.FItems[anIndex + 1];
      Exit;
    end;
  end;
  Result := nil;
end;

function TXmlNode.Get_TypedValue: Variant;
begin
	Result := Get_Text
end;

function TXmlNode.Get_XML: String;
var
  anXml: TStringBuilder;
begin
  anXml.Init;
  GetXML(anXml);
  anXml.GetString(Result);
end;

procedure TXmlNode.InsertBefore(const aChild, aBefore: IXmlNode);
var
	i: Integer;
	aChilds: TXmlNodeList;
begin
	aChilds := GetChilds;
	if Assigned(aBefore) then
		i := aChilds.IndexOfNode(aBefore.GetObject as TXmlNode)
	else
		i := aChilds.FCount;
	GetChilds.InsertNode(aChild.GetObject as TXmlNode, i)
end;

procedure TXmlNode.RemoveAllAttrs;
begin
	FAttrCount := 0; 
end;

procedure TXmlNode.RemoveAllChilds;
begin
	if Assigned(FChilds) then
		FChilds.ClearNodes
end;

procedure TXmlNode.RemoveAttr(const aName: String);
begin
	RemoveAttr(FNames.GetID(aName));
end;

procedure TXmlNode.RemoveAttr(aNameID: Integer);
var
	a1, a2: PXmlAttrData;
	i: Integer;
begin
  if FAttrCount = 0 then begin
    Exit;
  end;

	a1 := @FAttrs[0];
	i := 0;
	while (i < FAttrCount) and (a1.NameID <> aNameID) do begin
		Inc(a1);
		Inc(i)
	end;
	if i < FAttrCount then begin
		a2 := a1;
		Inc(a2);
		while i < FAttrCount - 1 do begin
			a1^ := a2^;
			Inc(a1);
			Inc(a2);
			Inc(i)
		end;
		VarClear(a1.Value);
		Dec(FAttrCount);
	end;
end;

procedure TXmlNode.RemoveChild(const aChild: IXmlNode);
begin
	GetChilds.RemoveNode(aChild.GetObject as TXmlNode)
end;

procedure TXmlNode.ReplaceChild(const aNewChild, anOldChild: IXmlNode);
var
	i: Integer;
	aChilds: TXmlNodeList;
begin
	aChilds := GetChilds;
	i := aChilds.IndexOfNode(anOldChild.GetObject as TXmlNode);
	if i <> -1 then
		aChilds.ReplaceNode(i, aNewChild.GetObject as TXmlNode)
end;

function NameCanBeginWith(aChar: Char): Boolean;
begin
	Result := (aChar = '_') or IsCharAlpha(aChar)
end;

function NameCanContain(aChar: Char): Boolean;
begin
	Result := (aChar = '_') or (aChar = '-') or (aChar = ':') or (aChar = '.') or
		IsCharAlphaNumeric(aChar)
end;

function IsName(const s: String): Boolean;
var
	i: Integer;
begin
	if s = '' then
		Result := False
	else if not NameCanBeginWith(s[1]) then
		Result := False
	else begin
		for i := 2 to Length(s) do
			if not NameCanContain(s[i]) then begin
				Result := False;
				Exit
			end;
		Result := True;
	end;
end;

const
	ntComment = -2;
	ntNode = -3;
	ntProcessingInstruction = -4;
	ntText = -5;
		
type
	TAxis = (axAncestor, axAncestorOrSelf, axAttribute, axChild,
		axDescendant, axDescendantOrSelf, axFollowing, axFollowingSibling,
		axParent, axPreceding, axPrecedingSibling, axSelf);

	TPredicate = class
		function Check(aNode: TXmlNode): Boolean; virtual; abstract;
	end;

	TLocationStep = class
		Next: TLocationStep;
		Axis: TAxis;
		NodeTest: Integer;
		Predicates: TList;
	end;
	


function TXmlNode.SelectNodes(
	const anExpression: String): IXmlNodeList;
var
	aNodes: TXmlNodeList;
	aChilds: TXmlNodeList;
	aChild: TXmlNode;
	aNameID: Integer;
	i: Integer;
{
	aPath: TXmlPath;
}
begin
	if IsName(anExpression) then begin
		aNodes := TXmlNodeList.Create(nil);
		Result := aNodes;
		aChilds := GetChilds;
		aNameID := FNames.GetID(anExpression);
		for i := 0 to aChilds.FCount - 1 do begin
			aChild := aChilds.FItems[i];
			if (aChild.Get_NodeType = NODE_ELEMENT) and (aChild.Get_NodeNameID = aNameID) then
				aNodes.InsertNode(aChild, aNodes.FCount);
		end;
	end
	else begin
		raise
			Exception.Create(SSimpleXmlError9);
{
		aPath := TXmlPath.Create;
		try
			aPath.Init(anExpression);
			Result := aPath.SelectNodes(Self);
		finally
			aPath.Free
		end
}
	end;
end;

function TXmlNode.SelectNodes(aNodeNameID: Integer): IXmlNodeList;
var
	aNodes: TXmlNodeList;
	aChilds: TXmlNodeList;
	aChild: TXmlNode;
	i: Integer;
begin
	aNodes := TXmlNodeList.Create(nil);
	Result := aNodes;
	aChilds := GetChilds;
	for i := 0 to aChilds.FCount - 1 do begin
		aChild := aChilds.FItems[i];
		if aChild.Get_NodeNameID = aNodeNameID then
			aNodes.InsertNode(aChild, aNodes.FCount);
	end;
end;

function TXmlNode.SelectSingleNode(const anExpression: String): IXmlNode;
var
	aChilds: TXmlNodeList;
	aChild: TXmlNode;
	aNameID: Integer;
	i: Integer;
begin
	if IsName(anExpression) then begin
		aChilds := GetChilds;
		aNameID := FNames.GetID(anExpression);
		for i := 0 to aChilds.FCount - 1 do begin
			aChild := aChilds.FItems[i];
			if (aChild.Get_NodeType = NODE_ELEMENT) and (aChild.Get_NodeNameID = aNameID) then begin
				Result := aChild;
				Exit
			end
		end;
		Result := nil;
	end
	else begin
		raise
			Exception.Create(SSimpleXmlError9)
	end
end;

function TXmlNode.FindElement(const anElementName, anAttrName: String; const anAttrValue: Variant): IXmlElement;
var
	aChild: TXmlNode;
	aNameID, anAttrNameID: Integer;
	i: Integer;
	pa: PXmlAttrData;
begin
	if Assigned(FChilds) then begin
		aNameID := FNames.GetID(anElementName);
		anAttrNameID := FNames.GetID(anAttrName);

		for i := 0 to FChilds.FCount - 1 do begin
			aChild := FChilds.FItems[i];
			if (aChild.Get_NodeType = NODE_ELEMENT) and (aChild.Get_NodeNameID = aNameID) then begin
				pa := aChild.FindAttrData(anAttrNameID);
				try
					if Assigned(pa) and VarSameValue(pa.Value, anAttrValue) then begin
						Result := aChild.AsElement;
						Exit
					end
				except
					// Исключительная ситуация может возникнуть в том случае,
					// если произойдет сбой в функции VarSameValue.
					// Иными словами - если значения нельзя сравнивать.
				end;
			end
		end;
	end;
	Result := nil;
end;

function TXmlNode.FindElements(const anElementName, anAttrName: String; const anAttrValue: Variant): IXmlNodeList;
var
  aNodes: TXmlNodeList;
	aChild: TXmlNode;
	aNameID, anAttrNameID: Integer;
	i: Integer;
	pa: PXmlAttrData;
begin
	aNodes := TXmlNodeList.Create(nil);
	Result := aNodes;
	if Assigned(FChilds) then begin
		aNameID := FNames.GetID(anElementName);
		anAttrNameID := FNames.GetID(anAttrName);

		for i := 0 to FChilds.FCount - 1 do begin
			aChild := FChilds.FItems[i];
			if (aChild.Get_NodeType = NODE_ELEMENT) and (aChild.Get_NodeNameID = aNameID) then begin
				pa := aChild.FindAttrData(anAttrNameID);
				try
					if Assigned(pa) and VarSameValue(pa.Value, anAttrValue) then
      			aNodes.InsertNode(aChild, aNodes.FCount);
				except
					// Исключительная ситуация может возникнуть в том случае,
					// если произойдет сбой в функции VarSameValue.
					// Иными словами - если значения нельзя сравнивать.
				end;
			end
		end;
	end;
end;

procedure TXmlNode.Set_TypedValue(const aValue: Variant);
begin
  Set_Text(aValue)
end;

procedure TXmlNode.SetAttr(const aName, aValue: String);
begin
	SetVarAttr(FNames.GetID(aName), aValue)
end;

procedure TXmlNode.SetAttr(aNameID: Integer; const aValue: String);
begin
	SetVarAttr(aNameID, aValue)
end;

procedure TXmlNode.SetBoolAttr(aNameID: Integer; aValue: Boolean);
begin
	SetVarAttr(aNameID, aValue)
end;

procedure TXmlNode.SetBoolAttr(const aName: String; aValue: Boolean);
begin
	SetVarAttr(FNames.GetID(aName), aValue)
end;

procedure TXmlNode.SetChildText(const aName: String;
	const aValue: String);
begin
	SetChildText(FNames.GetID(aName), aValue)
end;

procedure TXmlNode.SetChildText(aNameID: Integer; const aValue: String);
var
	aChild: TXmlNode;
begin
	aChild := FindFirstChild(aNameID);
	if not Assigned(aChild) then begin
		aChild := TXmlElement.Create(FNames, aNameID);
		with GetChilds do
			InsertNode(aChild, FCount);
	end;
	aChild.Set_Text(aValue)
end;

procedure TXmlNode.SetFloatAttr(aNameID: Integer; aValue: Double);
begin
	SetVarAttr(aNameID, aValue)
end;

procedure TXmlNode.SetFloatAttr(const aName: String; aValue: Double);
begin
	SetVarAttr(FNames.GetID(aName), aValue);
end;

procedure TXmlNode.SetHexAttr(const aName: String; aValue,
  aDigits: Integer);
begin
	SetVarAttr(FNames.GetID(aName), IntToHex(aValue, aDigits))
end;

procedure TXmlNode.SetHexAttr(aNameID, aValue, aDigits: Integer);
begin
	SetVarAttr(aNameID, IntToHex(aValue, aDigits))
end;

procedure TXmlNode.SetIntAttr(aNameID, aValue: Integer);
begin
	SetVarAttr(aNameID, aValue)
end;

procedure TXmlNode.SetIntAttr(const aName: String; aValue: Integer);
begin
	SetVarAttr(FNames.GetID(aName), aValue)
end;

procedure TXmlNode.SetVarAttr(const aName: String; aValue: Variant);
begin
  SetVarAttr(FNames.GetID(aName), aValue)
end;

procedure TXmlNode.SetVarAttr(aNameID: Integer; const aValue: Variant);
var
	anAttr: PXmlAttrData;
var
	aDelta: Integer;
begin
  if aNameID = -1 then
    raise Exception.Create(SSimpleXmlError27);

	anAttr := FindAttrData(aNameID);
	if not Assigned(anAttr) then begin
		if FAttrCount = Length(FAttrs) then begin
			if FAttrCount > 64 then
				aDelta := FAttrCount div 4
			else if FAttrCount > 8 then
				aDelta := 16
			else
				aDelta := 4;
			SetLength(FAttrs, FAttrCount + aDelta);
		end;
		anAttr := @FAttrs[FAttrCount];
		anAttr.NameID := aNameID;
		Inc(FAttrCount);
	end;
	anAttr.Value := aValue
end;

function TXmlNode.FindAttrData(aNameID: Integer): PXmlAttrData;
var
	i: Integer;
begin
  if FAttrCount = 0 then begin
    Result := nil;
    Exit;
  end;

	Result := @FAttrs[0];
	for i := 0 to FAttrCount - 1 do begin
		if Result.NameID = aNameID then begin
			Exit
    end
		else begin
			Inc(Result);
    end;
  end;
	Result := nil;
end;

function TXmlNode.AsElement: IXmlElement;
begin
	Result := nil
end;

function TXmlNode.AsCDATASection: IXmlCDATASection;
begin
	Result := nil                                                                  
end;

function TXmlNode.AsComment: IXmlComment;
begin
	Result := nil
end;

function TXmlNode.AsText: IXmlText;
begin
	Result := nil
end;

function TXmlNode.AsProcessingInstruction: IXmlProcessingInstruction;
begin
	Result := nil
end;

function TXmlNode.AppendCDATA(const aData: String): IXmlCDATASection;
var
	aChild: TXmlCDATASection;
begin
	aChild := TXmlCDATASection.Create(FNames, aData);
	GetChilds.InsertNode(aChild, -1);
	Result := aChild
end;

function TXmlNode.AppendComment(const aData: String): IXmlComment;
var
	aChild: TXmlComment;
begin
	aChild := TXmlComment.Create(FNames, aData);
	GetChilds.InsertNode(aChild, -1);
	Result := aChild
end;

function TXmlNode.AppendElement(const aName: String): IXmlElement;
var
	aChild: TXmlElement;
begin
	aChild := TXmlElement.Create(FNames, FNames.GetID(aName));
	GetChilds.InsertNode(aChild, -1);
	Result := aChild
end;

function TXmlNode.AppendElement(aNameID: Integer): IXmlElement;
var
	aChild: TXmlElement;
begin
	aChild := TXmlElement.Create(FNames, aNameID);
	GetChilds.InsertNode(aChild, -1);
	Result := aChild
end;

function TXmlNode.AppendProcessingInstruction(const aTarget,
  aData: String): IXmlProcessingInstruction;
var
	aChild: TXmlProcessingInstruction;
begin
	aChild := TXmlProcessingInstruction.Create(FNames, FNames.GetID(aTarget), aData);
	GetChilds.InsertNode(aChild, -1);
	Result := aChild
end;

function TXmlNode.AppendProcessingInstruction(aTargetID: Integer;
  const aData: String): IXmlProcessingInstruction;
var
	aChild: TXmlProcessingInstruction;
begin
	aChild := TXmlProcessingInstruction.Create(FNames, aTargetID, aData);
	GetChilds.InsertNode(aChild, -1);
	Result := aChild
end;

function TXmlNode.AppendText(const aData: String): IXmlText;
var
	aChild: TXmlText;
begin
	aChild := TXmlText.Create(FNames, aData);
	GetChilds.InsertNode(aChild, -1);
	Result := aChild
end;

procedure TXmlNode.GetAttrsXML(var anXml: TStringBuilder);
var
	a: PXmlAttrData;
	i: Integer;
begin
	if FAttrCount > 0 then begin
		a := @FAttrs[0];
		for i := 0 to FAttrCount - 1 do begin
			anXml.Add(' ' + FNames.GetName(a.NameID) + '="' + TextToXML(VarToXSTR(TVarData(a.Value))) + '"');
			Inc(a);
		end;
	end;
end;

procedure TXmlNode.LoadBinXml(aReader: TBinaryXmlReader);
var
	aCount: LongInt;
	a: PXmlAttrData;
	i: Integer;
begin
	// Считать атрибуты
	RemoveAllAttrs;
	aCount := aReader.ReadLongint;
	SetLength(FAttrs, aCount);
	FAttrCount := aCount;
  if aCount > 0 then begin
    a := @FAttrs[0];
    for i := 0 to aCount - 1 do begin
      a.NameID := aReader.ReadLongint;
      aReader.ReadVariant(TVarData(a.Value));
      Inc(a);
    end;
  end;

	// Считать дочерние узлы
	aCount := aReader.ReadLongint;
	if aCount > 0 then
		GetChilds.LoadBinXml(aReader, aCount, FNames);
end;

procedure TXmlNode.SaveBinXml(aWriter: TBinaryXmlWriter);
var
	aCount: LongInt;
	a: PXmlAttrData;
	i: Integer;
begin
	// Считать атрибуты
	aCount := FAttrCount;
	aWriter.WriteLongint(aCount);
  if aCount > 0 then begin
    a := @FAttrs[0];
    for i := 0 to aCount - 1 do begin
      aWriter.WriteLongint(a.NameID);
      aWriter.WriteVariant(TVarData(a.Value));
      Inc(a);
    end;
  end;

	// Записать дочерние узлы
	if Assigned(FChilds) then begin
		aWriter.WriteLongint(FChilds.FCount);
		FChilds.SaveBinXml(aWriter);
	end
	else
		aWriter.WriteLongint(0);
end;

function TXmlNode.Get_DataType: Integer;
begin
	Result := varString
end;

function TXmlNode.AttrExists(aNameID: Integer): Boolean;
begin
	Result := FindAttrData(aNameID) <> nil
end;

function TXmlNode.AttrExists(const aName: String): Boolean;
begin
	Result := FindAttrData(FNames.GetID(aName)) <> nil
end;

function TXmlNode.GetAttrType(aNameID: Integer): Integer;
var
	a: PXmlAttrData;
begin
	a := FindAttrData(aNameID);
	if Assigned(a) then begin
		Result := TVarData(a.Value).VType
  end
	else begin
		Result := varString
  end;
end;

function TXmlNode.GetAttrType(const aName: String): Integer;
begin
	Result := GetAttrType(FNames.GetID(aName));
end;

function TXmlNode.Get_Values(const aName: String): Variant;
var
	aChild: IXmlNode;
begin
	if aName = '' then
		Result := Get_TypedValue
	else if aName[1] = '@' then
		Result := GetVarAttr(Copy(aName, 2, Length(aName) - 1), '')
	else begin
		aChild := SelectSingleNode(aName);
		if Assigned(aChild) then
			Result := aChild.TypedValue
		else
			Result := ''
	end
end;

procedure TXmlNode.Set_Values(const aName: String; const aValue: Variant);
var
	aChild: IXmlNode;
begin
	if aName = '' then
		Set_TypedValue(aValue)
	else if aName[1] = '@' then
		SetVarAttr(Copy(aName, 2, Length(aName) - 1), aValue)
	else begin
		aChild := SelectSingleNode(aName);
		if not Assigned(aChild) then
			aChild := AppendElement(aName);
		aChild.TypedValue := aValue;
	end
end;

function TXmlNode.GetDateTimeAttr(aNameID: Integer;
	aDefault: TDateTime): TDateTime;
var
	anAttr: PXmlAttrData;
begin
	anAttr := FindAttrData(aNameID);
	if Assigned(anAttr) then begin
		if (VarType(anAttr.Value) = varString) or (VarType(anAttr.Value) = varOleStr) then
			Result := XSTRToDateTime(anAttr.Value)
		else
			Result := VarAsType(anAttr.Value, varDate)
	end
	else
		Result := aDefault;
end;

function TXmlNode.GetDateTimeAttr(const aName: String;
	aDefault: TDateTime): TDateTime;
begin
	Result := GetDateTimeAttr(FNames.GetID(aName), aDefault)
end;

procedure TXmlNode.SetDateTimeAttr(aNameID: Integer; aValue: TDateTime);
begin
	SetVarAttr(aNameID, VarAsType(aValue, varDate))
end;

procedure TXmlNode.SetDateTimeAttr(const aName: String;
	aValue: TDateTime);
begin
	SetVarAttr(aName, VarAsType(aValue, varDate))
end;

function TXmlNode.EnsureChild(aNameID: Integer): IXmlNode;
var
	aChild: TXmlNode;
begin
	aChild := FindFirstChild(aNameID);
	if Assigned(aChild) then
		Result := aChild
	else
		Result := AppendElement(aNameID)
end;

function TXmlNode.EnsureChild(const aName: String): IXmlNode;
begin
	Result := EnsureChild(FNames.GetID(aName))
end;

function TXmlNode.NeedChild(aNameID: Integer): IXmlNode;
var
	aChild: TXmlNode;
begin
	aChild := FindFirstChild(aNameID);
	if not Assigned(aChild) then
		raise Exception.CreateFmt(SSimpleXmlError10, [FNames.GetName(aNameID)]);
	Result := aChild
end;

function TXmlNode.NeedChild(const aName: String): IXmlNode;
begin
	Result := NeedChild(FNames.GetID(aName));
end;

procedure TXmlNode.SetNameTable(aValue: TXmlNameTable; aMap: TList);
var
	i: Integer;
	aNewMap: Boolean;
begin
	if aValue <> FNames then begin
		aNewMap := not Assigned(aMap);
		if aNewMap then begin
			aMap := TList.Create;
			for i := 0 to Length(FNames.FNames) - 1 do
				aMap.Add(Pointer(aValue.GetID(FNames.FNames[i])));
		end;
		try
			SetNodeNameID(Integer(aMap[Get_NodeNameID]));
			for i := 0 to Length(FAttrs) - 1 do
				with FAttrs[i] do
					NameID := Integer(aMap[NameID]);
			FNames._Release;
			FNames := aValue;
			aValue._AddRef;
			if Assigned(FChilds) then
				for i := 0 to FChilds.FCount - 1 do
					FChilds.FItems[i].SetNameTable(aValue, aMap);
		finally
			if aNewMap then
				aMap.Free
		end;
	end;
end;

procedure TXmlNode.SetNodeNameID(aValue: Integer);
begin

end;


function TXmlNode.CloneNode(aDeep: Boolean): IXmlNode;
begin
	Result := DoCloneNode(aDeep)
end;


function TXmlNode.Get_SourceLine: Integer;
begin
	Result := FSourceLine
end;

function TXmlNode.Get_SourceCol: Integer;
begin
	Result := FSourceCol
end;

function TXmlNode.GetTextAsBinaryData: RawByteString;
begin
	Result := Base64ToBin(Get_Text);
end;

function TXmlNode.GetOwnText: String;
var
	i: Integer;
  sb: TStringBuilder;
begin
  sb.Init;
	for i := 0 to GetChilds.FCount - 1 do
		with FChilds.FItems[i] do
			if Get_NodeType in [NODE_TEXT, NODE_CDATA_SECTION] then
        sb.Add(Get_Text);
	sb.GetString(Result);
end;

procedure TXmlNode.ReplaceTextByBinaryData(const aData; aSize: Integer;
	aMaxLineLength: Integer);
begin
	RemoveTextNodes;
	GetChilds.InsertNode(TXmlText.Create(FNames, BinToBase64(aData, aSize, aMaxLineLength)), -1);
end;

procedure TXmlNode.RemoveTextNodes;
var
	i: Integer;
	aNode: TXmlNode;
begin
	if Assigned(FChilds) then
		for i := FChilds.FCount - 1 downto 0 do begin
			aNode := FChilds.FItems[i];
			if aNode.Get_NodeType in [NODE_TEXT, NODE_CDATA_SECTION] then
				FChilds.RemoveNode(aNode);
		end;
end;

procedure TXmlNode.ReplaceTextByCDATASection(const aText: String);

	procedure AddCDATASection(const aText: String);
	var
		i: Integer;
		aChilds: TXmlNodeList;
	begin
		i := Pos(']]>', aText);
		aChilds := GetChilds;
		if i = 0 then
			aChilds.InsertNode(TXmlCDATASection.Create(FNames, aText), aChilds.FCount)
		else begin
			aChilds.InsertNode(TXmlCDATASection.Create(FNames, Copy(aText, 1, i)), aChilds.FCount);
			AddCDATASection(Copy(aText, i + 1, Length(aText) - i - 1));
		end;
	end;

begin
	RemoveTextNodes;
	AddCDATASection(aText);
end;

{ TXmlElement }

constructor TXmlElement.Create(aNames: TXmlNameTable; aNameID: Integer);
begin
	inherited Create(aNames);
	FNameID := aNameID;
end;

function TXmlElement.Get_NodeNameID: Integer;
begin
	Result := FNameID
end;

function TXmlElement.Get_NodeType: Integer;
begin
	Result := NODE_ELEMENT
end;

function TXmlElement.GetChilds: TXmlNodeList;
var
  aText: String;
begin
	Result := inherited GetChilds;
	if not (VarIsEmpty(FData) or VarIsNull(FData)) then begin
    aText := VarToXSTR(TVarData(FData));
		VarClear(FData);
    if aText <> '' then
      AppendText(aText);
	end;
end;

function TXmlElement.Get_Text: String;
var
	aChilds: TXmlNodeList;
	aChild: TXmlNode;
	aChildText: String;
	i: Integer;
begin
	Result := '';
	if Assigned(FChilds) and (FChilds.FCount > 0) then begin
		aChilds := FChilds;
		for i := 0 to aChilds.FCount - 1 do begin
			aChild := aChilds.FItems[i];
			if aChild.Get_NodeType in [NODE_ELEMENT, NODE_TEXT, NODE_CDATA_SECTION] then begin
				aChildText := aChild.Get_Text;
				if aChildText <> '' then
					if Result = '' then
						Result := aChildText
					else
						Result := Result + ' ' + aChildText
			end
		end;
	end
	else if VarIsEmpty(FData) then
		Result := ''
	else
		Result := VarToXSTR(TVarData(FData))
end;

procedure TXmlElement.Set_Text(const aValue: String);
begin
	if Assigned(FChilds) then
		FChilds.ClearNodes;
	FData := aValue;
end;

function TXmlElement.AsElement: IXmlElement;
begin
	Result := Self
end;

var
	FGetXMLIntend: Integer = 0;

function GetIndentStr: String;
var
	i: Integer;
begin
	SetLength(Result, FGetXMLIntend*Length(DefaultIndentText));
	for i := 0 to FGetXMLIntend - 1 do
		Move(DefaultIndentText[1], Result[i*Length(DefaultIndentText) + 1], Length(DefaultIndentText));
end;

function HasCRLF(const s: String): Boolean;
var
	i: Integer;
begin
	for i := 1 to Length(s) do
		if (s[i] = ^M) or (s[i] = ^J) then begin
			Result := True;
			Exit
		end;
	Result := False;
end;

function EndWithCRLF(const s: String): Boolean;
begin
	Result :=
		(Length(s) > 1) and
		(s[Length(s) - 1] = ^M) and
		(s[Length(s)] = ^J);
end;

procedure TXmlElement.GetXML(var anXml: TStringBuilder);
var
	aChildsXMLSB: TStringBuilder;
  aChildsXML: String;
	aTag: String;
	aDoc: TXmlDocument;
	aPreserveWhiteSpace: Boolean;
  aSaveLength: Integer;
begin
	aDoc := GetOwnerDocument;
	if Assigned(aDoc) then
		aPreserveWhiteSpace := aDoc.Get_PreserveWhiteSpace
	else
		aPreserveWhiteSpace := DefaultPreserveWhiteSpace;
	if aPreserveWhiteSpace then begin
		aTag := FNames.GetName(FNameID);
		anXml.Add('<');
    anXml.Add(aTag);
    GetAttrsXML(anXml);
		anXml.Add(' ');
    aSaveLength := anXml.FLength;
		if Assigned(FChilds) and (FChilds.FCount > 0) then
			FChilds.GetXML(anXml)
		else if not VarIsEmpty(FData) then
			anXml.Add(TextToXML(VarToXSTR(TVarData(FData))));

		if anXml.FLength = aSaveLength then begin
      anXml.FData[aSaveLength] := '/';
			anXml.Add('>')
    end
		else begin
      anXml.FData[aSaveLength] := '>';
			anXml.Add('</');
      anXml.Add(aTag);
      anXml.Add('>')
    end
	end
	else begin
		if Assigned(FChilds) and (FChilds.FCount > 0) then begin
			Inc(FGetXMLIntend);
			try
        aChildsXMLSB.Init;
				FChilds.GetXML(aChildsXMLSB);
        aChildsXMLSB.GetString(aChildsXML);
			finally
				Dec(FGetXMLIntend)
			end
		end
		else if VarIsEmpty(FData) then
      aChildsXML := ''
    else
			aChildsXML := TextToXML(VarToXSTR(TVarData(FData)));
		aTag := FNames.GetName(FNameID);
		anXml.Add(^M^J); anXml.Add(GetIndentStr); anXml.Add('<'); anXml.Add(aTag);
    GetAttrsXML(anXml);
		if aChildsXML = '' then
			anXml.Add('/>')
		else if HasCRLF(aChildsXML) then
			if EndWithCRLF(aChildsXML) then begin
				anXml.Add('>'); anXml.Add(aChildsXML); anXml.Add(GetIndentStr);
        anXml.Add('</'); anXml.Add(aTag); anXml.Add('>')
      end
			else begin
				anXml.Add('>'); anXml.Add(aChildsXML); anXml.Add(^M^J); anXml.Add(GetIndentStr);
        anXml.Add('</'); anXml.Add(aTag); anXml.Add('>')
      end
		else begin
			anXml.Add('>');
      anXml.Add(aChildsXML);
      anXml.Add('</');
      anXml.Add(aTag);
      anXml.Add('>');
    end
	end;
end;

function TXmlElement.Get_TypedValue: Variant;
begin
	if Assigned(FChilds) and (FChilds.FCount > 0) then
		Result := Get_Text
	else 
		Result := FData
end;

procedure TXmlElement.Set_TypedValue(const aValue: Variant);
begin
	if Assigned(FChilds) then
		FChilds.ClearNodes;
	FData := aValue;
end;

function TXmlElement.Get_DataType: Integer;
begin
	if (Assigned(FChilds) and (FChilds.FCount > 0)) or VarIsEmpty(FData) then begin
		Result := varString
  end
	else begin
		Result := TVarData(FData).VType;
  end;
end;

function TXmlElement.Get_ChildNodes: IXmlNodeList;
begin
	Result := inherited Get_ChildNodes;
end;

procedure TXmlElement.SetNodeNameID(aValue: Integer);
begin
	FNameID := aValue
end;

function TXmlElement.DoCloneNode(aDeep: Boolean): IXmlNode;
var
	aClone: TXmlElement;
	i: Integer;
begin
	aClone := TXmlElement.Create(FNames, FNameID);
	Result := aClone;
	SetLength(aClone.FAttrs, FAttrCount);
	aClone.FAttrCount := FAttrCount;
	for i := 0 to FAttrCount - 1 do
		aClone.FAttrs[i] := FAttrs[i];
  aClone.FData := FData;
	if aDeep and Assigned(FChilds) and (FChilds.FCount > 0) then
		for i := 0 to FChilds.FCount - 1 do
			aClone.AppendChild(FChilds.FItems[i].CloneNode(True));
end;

{ TXmlCharacterData }

constructor TXmlCharacterData.Create(aNames: TXmlNameTable;
  const aData: String);
begin
	inherited Create(aNames);
	FData := aData;
end;

function TXmlCharacterData.Get_Text: String;
var
	aDoc: TXmlDocument;
	aPreserveWhiteSpace: Boolean;
begin
	aDoc := GetOwnerDocument;
	if Assigned(aDoc) then
		aPreserveWhiteSpace := aDoc.Get_PreserveWhiteSpace
	else
		aPreserveWhiteSpace := DefaultPreserveWhiteSpace;
	if aPreserveWhiteSpace then
		Result := FData
	else
		Result := Trim(FData);
end;

procedure TXmlCharacterData.Set_Text(const aValue: String);
begin
	FData := aValue
end;

{ TXmlText }

function TXmlText.AsText: IXmlText;
begin
	Result := Self;
end;

constructor TXmlText.Create(aNames: TXmlNameTable; const aData: Variant);
begin
	inherited Create(aNames);
	FData := aData;
end;

function TXmlText.DoCloneNode(aDeep: Boolean): IXmlNode;
begin
	Result := TXmlText.Create(FNames, FData);
end;

function TXmlText.Get_DataType: Integer;
begin
	Result := TVarData(FData).VType
end;

function TXmlText.Get_NodeNameID: Integer;
begin
	Result := FNames.FXmlTextNameID
end;

function TXmlText.Get_NodeType: Integer;
begin
	Result := NODE_TEXT
end;

function TXmlText.Get_Text: String;
begin
	Result := VarToXSTR(TVarData(FData))
end;

function TXmlText.Get_TypedValue: Variant;
begin
	Result := FData
end;

procedure TXmlText.GetXML(var anXml: TStringBuilder);
begin
	anXml.Add(TextToXML(VarToXSTR(TVarData(FData))));
end;

procedure TXmlText.Set_Text(const aValue: String);
begin
	FData := aValue
end;

procedure TXmlText.Set_TypedValue(const aValue: Variant);
begin
	FData := aValue
end;

{ TXmlCDATASection }

function TXmlCDATASection.AsCDATASection: IXmlCDATASection;
begin
	Result := Self
end;

function TXmlCDATASection.DoCloneNode(aDeep: Boolean): IXmlNode;
begin
  Result := TXmlCDATASection.Create(FNames, FData);
end;

function TXmlCDATASection.Get_NodeNameID: Integer;
begin
	Result := FNames.FXmlCDATASectionNameID
end;

function TXmlCDATASection.Get_NodeType: Integer;
begin
	Result := NODE_CDATA_SECTION
end;

function GenCDATAXML(const aValue: String): String;
var
	i: Integer;
begin
	i := Pos(']]>', aValue);
	if i = 0 then
		Result := '<![CDATA[' + aValue + ']]>'
	else
		Result := '<![CDATA[' + Copy(aValue, 1, i) + ']]>' + GenCDATAXML(Copy(aValue, i + 1, Length(aValue) - i - 1));
end;

procedure TXmlCDATASection.GetXML(var anXml: TStringBuilder);
begin
  anXml.Add(GenCDATAXML(FData));
end;

{ TXmlComment }

function TXmlComment.AsComment: IXmlComment;
begin
	Result := Self
end;

function TXmlComment.DoCloneNode(aDeep: Boolean): IXmlNode;
begin
	Result := TXmlComment.Create(FNames, FData);
end;

function TXmlComment.Get_NodeNameID: Integer;
begin
	Result := FNames.FXmlCommentNameID
end;

function TXmlComment.Get_NodeType: Integer;
begin
	Result := NODE_COMMENT
end;

procedure TXmlComment.GetXML(var anXml: TStringBuilder);
begin
	anXml.Add('<!--');
  anXml.Add(FData);
  anXml.Add('-->');
end;

{ TXmlDocument }

constructor TXmlDocument.Create(aNames: TXmlNameTable);
begin
	inherited Create(aNames);
  FPreserveWhiteSpace := DefaultPreserveWhiteSpace;
end;

function TXmlDocument.CreateCDATASection(
	const aData: String): IXmlCDATASection;
begin
	Result := TXmlCDATASection.Create(FNames, aData)
end;

function TXmlDocument.CreateComment(const aData: String): IXmlComment;
begin
	Result := TXmlComment.Create(FNames, aData) 
end;

function TXmlDocument.CreateElement(aNameID: Integer): IXmlElement;
begin
	Result := TXmlElement.Create(FNames, aNameID)
end;

function TXmlDocument.CreateElement(const aName: String): IXmlElement;
begin
	Result := TXmlElement.Create(FNames, FNames.GetID(aName));
end;

function TXmlDocument.CreateProcessingInstruction(const aTarget,
	aData: String): IXmlProcessingInstruction;
begin
	Result := TXmlProcessingInstruction.Create(FNames, FNames.GetID(aTarget), aData)
end;

function TXmlDocument.CreateProcessingInstruction(aTargetID: Integer;
	const aData: String): IXmlProcessingInstruction;
begin
	Result := TXmlProcessingInstruction.Create(FNames, aTargetID, aData)
end;

function TXmlDocument.CreateText(const aData: String): IXmlText;
begin
	Result := TXmlText.Create(FNames, aData)
end;

function TXmlDocument.DoCloneNode(aDeep: Boolean): IXmlNode;
var
	aClone: TXmlDocument;
	i: Integer;
begin
	aClone := TXmlDocument.Create(FNames);
	Result := aClone;
	if aDeep and Assigned(FChilds) and (FChilds.FCount > 0) then
		for i := 0 to FChilds.FCount - 1 do
			aClone.AppendChild(FChilds.FItems[i].CloneNode(True));
end;

function TXmlDocument.Get_BinaryXML: RawByteString;
var
	aWriter: TRawByteStringBinaryXmlWriter;
begin
	aWriter := TRawByteStringBinaryXmlWriter.Create(0, $10000);
	try
		FNames.SaveBinXml(aWriter);
		SaveBinXml(aWriter);
		aWriter.FlushBuf;
		Result := aWriter.FData;
	finally
		aWriter.Free
	end
end;

function TXmlDocument.Get_DocumentElement: IXmlElement;
var
	aChilds: TXmlNodeList;
	aChild: TXmlNode;
	i: Integer;
begin
	aChilds := GetChilds;
	for i := 0 to aChilds.FCount - 1 do begin
		aChild := aChilds.FItems[i];
		if aChild.Get_NodeType = NODE_ELEMENT then begin
			Result := aChild.AsElement;
			Exit
		end
	end;
	Result := nil;
end;

function TXmlDocument.Get_NodeNameID: Integer;
begin
	Result := FNames.FXmlDocumentNameID
end;

function TXmlDocument.Get_NodeType: Integer;
begin
	Result := NODE_DOCUMENT
end;

function TXmlDocument.Get_PreserveWhiteSpace: Boolean;
begin
	Result := FPreserveWhiteSpace;
end;

function TXmlDocument.Get_Text: String;
var
	aChilds: TXmlNodeList;
	aChild: TXmlNode;
	aChildText: String;
	i: Integer;
begin
	Result := '';
	aChilds := GetChilds;
	for i := 0 to aChilds.FCount - 1 do begin
		aChild := aChilds.FItems[i];
		if aChild.Get_NodeType in [NODE_ELEMENT, NODE_TEXT, NODE_CDATA_SECTION] then begin
			aChildText := aChild.Get_Text;
			if aChildText <> '' then
				if Result = '' then
					Result := aChildText
				else
					Result := Result + ' ' + aChildText
		end
	end;
end;

procedure TXmlDocument.GetXML(var anXml: TStringBuilder);
begin
	GetChilds.GetXML(anXml)
end;

procedure TXmlDocument.Load(aStream: TStream);
var
	anXml: TAnsiStreamXmlSource;
	aBinarySign: RawByteString;
	aReader: TBinaryXmlReader;
begin
	RemoveAllChilds;
	RemoveAllAttrs;
	if aStream.Size > BinXmlSignatureSize then begin
		SetLength(aBinarySign, BinXmlSignatureSize);
		aStream.ReadBuffer(aBinarySign[1], BinXmlSignatureSize);
		if aBinarySign = BinXmlSignature then begin
			FNames._Release;
			FNames := TXmlNameTable.Create(4096);
			FNames._AddRef;
			aReader := TStreamBinaryXmlReader.Create(aStream, $10000);
			try
				FNames.LoadBinXml(aReader);
				LoadBinXml(aReader);
			finally
				aReader.Free
			end;
			Exit;
		end;
		aStream.Position := aStream.Position - BinXmlSignatureSize;
	end;
	anXml := TAnsiStreamXmlSource.Create(aStream, 1 shl 16);
	try
		GetChilds.ParseXML(anXml, FNames, FPreserveWhiteSpace);
	finally
		anXml.Free
	end
end;

procedure TXmlDocument.Load(const aFileName: String);
var
	aFile: TFileStream;
begin
	aFile := TFileStream.Create(aFileName, fmOpenRead or fmShareDenyWrite, fmShareDenyWrite);
	try
    try
  		Load(aFile);
    except
      on E: Exception do begin
        E.Message := format(SSimpleXmlError26, [E.Message, aFileName]);
        raise;
      end;
    end;
	finally
		aFile.Free
	end
end;

procedure TXmlDocument.LoadBinaryXML(const anXml: RawByteString);
var
	aReader: TRawByteStringBinaryXmlReader;
begin
	RemoveAllChilds;
	RemoveAllAttrs;
	aReader := TRawByteStringBinaryXmlReader.Create(anXml);
	try
		FNames._Release;
		FNames := TXmlNameTable.Create(4096);
		FNames._AddRef;
		FNames.LoadBinXml(aReader);
		LoadBinXml(aReader);
	finally
		aReader.Free
	end
end;

procedure TXmlDocument.LoadResource(aType, aName: PChar);
var
	aRSRC: HRSRC;
	aGlobal: HGLOBAL;
	aSize: DWORD;
	aPointer: Pointer;
	aStream: TStringStream;
begin
	aRSRC := FindResource(HInstance, aName, aType);
	if aRSRC <> 0 then begin
		aGlobal := Windows.LoadResource(HInstance, aRSRC);
		aSize := SizeofResource(HInstance, aRSRC);
		if (aGlobal <> 0) and (aSize <> 0) then begin
			aPointer := LockResource(aGlobal);
			if Assigned(aPointer) then begin
				aStream := TStringStream.Create('');
				try
					aStream.WriteBuffer(aPointer^, aSize);
					LoadXML(aStream.DataString);
				finally
					aStream.Free;
				end;
			end;
		end;
	end;
end;

procedure TXmlDocument.LoadXML(const anXml: String);
var
	aSource: TStringXmlSource;
begin
  RemoveAllChilds;
  RemoveAllAttrs;
  aSource := TStringXmlSource.Create(anXml);
  try
    GetChilds.ParseXML(aSource, FNames, FPreserveWhiteSpace);
  finally
    aSource.Free
  end
end;

{$if CompilerVersion >= 20}
procedure TXmlDocument.LoadXML(const anXml: RawByteString);
var
	aSource: TStringXmlSource;
begin
	if XmlIsInBinaryFormat(anXml) then begin
		LoadBinaryXML(anXml)
  end
	else begin
		RemoveAllChilds;
		RemoveAllAttrs;
		aSource := TStringXmlSource.Create(String(anXml));
		try
			GetChilds.ParseXML(aSource, FNames, FPreserveWhiteSpace);
		finally
			aSource.Free
		end
	end
end;
{$ifend}

function TXmlDocument.NewDocument(const aVersion, anEncoding,
	aRootElementName: String): IXmlElement;
begin
	Result := NewDocument(aVersion, anEncoding, FNames.GetID(aRootElementName));
end;

function TXmlDocument.NewDocument(const aVersion, anEncoding: String;
	aRootElementNameID: Integer): IXmlElement;
var
	aChilds: TXmlNodeList;
	aRoot: TXmlElement;
	e: String;
begin
	aChilds := GetChilds;
	aChilds.ClearNodes;
	if anEncoding = '' then
		e := DefaultEncoding
	else
		e := anEncoding;
	aChilds.InsertNode(TXmlProcessingInstruction.Create(FNames, FNames.FXmlID,
		'version="' + aVersion + '" encoding="' + e + '"'), 0);
	aRoot := TXmlElement.Create(FNames, aRootElementNameID);
	aChilds.InsertNode(aRoot, 1);
	Result := aRoot;
end;

procedure TXmlDocument.Save(aStream: TStream);
var
	anXml: TStringBuilder;
begin
	anXml.Init;
	GetXML(anXml);
  if anXml.FLength > 0 then begin
  	aStream.WriteBuffer(anXml.FData[1], sizeof(Char)*anXml.FLength);
  end;
end;

procedure TXmlDocument.Save(const aFileName: String);
var
	aFile: TFileStream;
begin
	if FileExists(aFileName) then begin
		aFile := TFileStream.Create(aFileName, fmOpenWrite or fmShareDenyWrite);
		aFile.Size := 0;
	end
	else begin
		aFile := TFileStream.Create(aFileName, fmCreate);
	end;

	try
		Save(aFile);
	finally
		aFile.Free
	end
end;

procedure TXmlDocument.SaveBinary(aStream: TStream; anOptions: LongWord);
var
	aWriter: TBinaryXmlWriter;
begin
	aWriter := TStreamBinrayXmlWriter.Create(aStream, anOptions, 65536);
	try
		FNames.SaveBinXml(aWriter);
		SaveBinXml(aWriter);
	finally
		aWriter.Free
	end
end;

procedure TXmlDocument.SaveBinary(const aFileName: String; anOptions: LongWord);
var
	aFile: TFileStream;
begin
	aFile := TFileStream.Create(aFileName, fmCreate or fmShareDenyWrite);
	try
		SaveBinary(aFile, anOptions);
	finally
		aFile.Free
	end
end;

procedure TXmlDocument.Set_PreserveWhiteSpace(aValue: Boolean);
begin
	FPreserveWhiteSpace := aValue;
end;

procedure TXmlDocument.Set_Text(const aText: String);
var
	aChilds: TXmlNodeList;
begin
	aChilds := GetChilds;
	aChilds.ClearNodes;
	aChilds.InsertNode(TXmlText.Create(FNames, aText), 0);
end;

{ TXmlProcessingInstruction }

function TXmlProcessingInstruction.AsProcessingInstruction: IXmlProcessingInstruction;
begin
	Result := Self
end;

constructor TXmlProcessingInstruction.Create(aNames: TXmlNameTable;
  aTargetID: Integer; const aData: String);
begin
	inherited Create(aNames);
	FTargetID := aTargetID;
	FData := aData;
end;

function TXmlProcessingInstruction.DoCloneNode(aDeep: Boolean): IXmlNode;
begin
	Result := TXmlProcessingInstruction.Create(FNames, FTargetID, FData);
end;

function TXmlProcessingInstruction.Get_NodeNameID: Integer;
begin
	Result := FTargetID
end;

function TXmlProcessingInstruction.Get_NodeType: Integer;
begin
	Result := NODE_PROCESSING_INSTRUCTION
end;

function TXmlProcessingInstruction.Get_Text: String;
begin
	Result := FData; 
end;

procedure TXmlProcessingInstruction.GetXML(var anXml: TStringBuilder);
begin
	anXml.Add('<?' + FNames.GetName(FTargetID));
	if FData = '' then
		GetAttrsXML(anXml)
	else
		anXml.Add(' ' + FData);
	anXml.Add('?>');
end;

function TXmlProcessingInstruction.Get_Target: String;
begin
  Result := FNames.GetName(FTargetID);
end;

procedure TXmlProcessingInstruction.SetNodeNameID(aValue: Integer);
begin
	FTargetID := aValue
end;

procedure TXmlProcessingInstruction.Set_Text(const aText: String);
begin
	FData := aText
end;

{ TXmlStrSource }

constructor TStringXmlSource.Create(const aSource: String);
begin
	inherited Create;
	FSource := aSource;
	FSourcePtr := PChar(FSource);
	FSourceEnd := FSourcePtr + Length(FSource);
	if FSourcePtr = FSourceEnd then
		CurChar := #0
	else 
		CurChar := FSourcePtr^;
end;

function TStringXmlSource.EOF: Boolean;
begin
	Result := FSourcePtr = FSourceEnd
end;

function TStringXmlSource.DoNext: Boolean;
begin
	if FSourcePtr < FSourceEnd then
		Inc(FSourcePtr);
	if FSourcePtr = FSourceEnd then begin
		Result := False;
		CurChar := #0;
	end
	else begin
		Result := True;
		CurChar := FSourcePtr^;
	end;
end;

{ TXmlSource }

procedure TXmlSource.NewToken;
begin
	Inc(FTokenStackTop);
	if FTokenStackTop < Length(FTokenStack) then begin
		FToken := FTokenStack[FTokenStackTop];
		FToken.Clear
	end
	else begin
		SetLength(FTokenStack, FTokenStackTop + 1);
		FToken := TXmlToken.Create;
		FTokenStack[FTokenStackTop] := FToken;
	end
end;

function TXmlSource.AcceptToken: String;
begin
	SetLength(Result, FToken.FValuePtr - FToken.ValueStart);
	if Length(Result) > 0 then begin
		Move(FToken.ValueStart^, Result[1], Length(Result)*sizeof(Char));
  end;
	DropToken;
end;

function TXmlSource.Next: Boolean;
begin
	Result := DoNext;
	if Result then begin
		if (CurChar = ^M) or (CurChar = ^J) and (FPrevChar <> ^M) and (FPrevChar <> ^J) then begin
			Inc(FCurLine);
			FCurPos := 0;
		end
		else if CurChar <> ^J then begin
			Inc(FCurPos);
    end;
		FPrevChar := CurChar;
	end;
end;

procedure TXmlSource.SkipBlanks;
begin
	while not EOF and (CurChar <= ' ') do
		Next;
end;

// на входе - первый символ имени
// на выходе - первый символ, который не является допустимым для имен
function TXmlSource.ExpectXmlName: String;
begin
	if not NameCanBeginWith(CurChar) then
		raise Exception.CreateFmt(SSimpleXmlError11, [FCurLine, FCurPos]);
	NewToken;
	AppendTokenChar(CurChar);
	while Next and NameCanContain(CurChar) do
		AppendTokenChar(CurChar);
	Result := AcceptToken;
end;

// на входе - первый символ числа
// на выходе - первый символ, который не является допустимым для чисел
function TXmlSource.ExpectDecimalInteger: Integer;
var
	s: String;
	e: Integer;
begin
	NewToken;
	while (CurChar >= '0') and (CurChar <= '9') do begin
		AppendTokenChar(CurChar);
		Next;
	end;
	s := AcceptToken;
	if Length(s) = 0 then
		raise Exception.CreateFmt(SSimpleXmlError12, [FCurLine, FCurPos]);
	Val(s, Result, e);
end;

function IsHexDigit(c: Char): Boolean;
begin
  Result := (c >= '0') and (c <= '9') or (c >= 'A') and (c <= 'F') or (c >= 'a') and (c <= 'f')
end;

// на входе - первый символ числа
// на выходе - первый символ, который не является допустимым для
//  щестнадцатиричных чисел
function TXmlSource.ExpectHexInteger: Integer;
var
	s: String;
	e: Integer;
begin
	NewToken;
	while IsHexDigit(CurChar) do begin
		AppendTokenChar(CurChar);
		Next;
	end;
	s := '$';
	s := s + AcceptToken;
	if Length(s) = 1 then begin
		raise Exception.CreateFmt(SSimpleXmlError13, [FCurLine, FCurPos]);
  end;
	Val(s, Result, e);
end;

// на входе: "&"
// на выходе: следующий за ";"
function TXmlSource.ExpectXmlEntity: Char;
var
	s: String;
begin
	if not Next then begin
		raise Exception.CreateFmt(SSimpleXmlError14, [FCurLine, FCurPos]);
  end;
	if CurChar = '#' then begin
		if not Next then begin
			raise Exception.CreateFmt(SSimpleXmlError12, [FCurLine, FCurPos]);
    end;
		if CurChar = 'x' then begin
			Next;
			Result := Char(ExpectHexInteger);
		end
		else begin
			Result := Char(ExpectDecimalInteger);
    end;
		ExpectChar(';');
	end
	else begin
		s := ExpectXmlName;
		ExpectChar(';');
		if s = 'amp' then begin
			Result := '&'
    end
		else if s = 'quot' then begin
			Result := '"'
    end
		else if s = 'lt' then begin
			Result := '<'
    end
		else if s = 'gt' then begin
			Result := '>'
    end
		else if s = 'apos' then begin
			Result := ''''
    end
		else begin
			raise Exception.CreateFmt(SSimpleXmlError15, [FCurLine, FCurPos]);
    end;
	end
end;

procedure TXmlSource.ExpectChar(aChar: Char);
begin
	if EOF or (CurChar <> aChar) then begin
		raise Exception.CreateFmt(SSimpleXmlError16, [aChar, FCurLine, FCurPos]);
  end;
	Next;
end;

procedure TXmlSource.ExpectText(aText: PChar);
begin
	while aText^ <> #0 do begin
		if (CurChar <> aText^) or EOF then begin
			raise Exception.CreateFmt(SSimpleXmlError17, [aText, FCurLine, FCurPos]);
    end;
		Inc(aText);
		Next;
	end;
end;

// на входе: открывающая кавычка
// на выходе: символ, следующий за закрывающей кавычкой
function TXmlSource.ExpectQuotedText(aQuote: Char): String;
begin
	NewToken;
	Next;
	while not EOF and (CurChar <> aQuote) do begin
		if CurChar = '&' then begin
			AppendTokenChar(ExpectXmlEntity)
    end
		else if CurChar = '<' then begin
			raise Exception.CreateFmt(SSimpleXmlError18, [FCurLine, FCurPos])
    end
		else begin
			AppendTokenChar(CurChar);
			Next;
		end
	end;
	if EOF then begin
		raise Exception.CreateFmt(SimpleXmlError19, [aQuote, FCurLine, FCurPos]);
  end;
	Next;
	Result := AcceptToken;
end;

procedure TXmlSource.ParseAttrs(aNode: TXmlNode);
var
	aName: String;
	aValue: String;
begin
	SkipBlanks;
	while not EOF and NameCanBeginWith(CurChar) do begin
		aName := ExpectXmlName;
		SkipBlanks;
		ExpectChar('=');
		SkipBlanks;
		if EOF then begin
			raise Exception.CreateFmt(SSimpleXmlError20, [FCurLine, FCurPos]);
    end;
		if (CurChar = '''') or (CurChar = '"') then begin
			aValue := ExpectQuotedText(CurChar)
    end
		else begin
			raise Exception.CreateFmt(SSimpleXmlError21, [FCurLine, FCurPos]);
    end;
		aNode.SetAttr(aName, aValue);
		SkipBlanks;
	end;
end;

function StrEquals(p1, p2: PChar; aLen: Integer): Boolean;
begin
	while aLen > 0 do
		if p1^ <> p2^ then begin
			Result := False;
			Exit
		end
		else if (p1^ = #0) or (p2^ = #0) then begin
			Result := p1^ = p2^;
			Exit
		end
		else begin
			Inc(p1);
			Inc(p2);
			Dec(aLen);
		end;
	Result := True;
end;

// на входе: первый символ текста
// на выходе: символ, следующий за последним символом ограничителя
function TXmlSource.ParseTo(aText: PChar): String;
var
	aCheck: PChar;
	p: PChar;
begin
	NewToken;
	aCheck := aText;
	while not EOF do begin
		if CurChar = aCheck^ then begin
			Inc(aCheck);
			Next;
			if aCheck^ = #0 then begin
				Result := AcceptToken;
				Exit;
			end;
		end
		else if aCheck = aText then begin
			AppendTokenChar(CurChar);
			Next;
		end
		else begin
			p := aText + 1;
			while (p < aCheck) and not StrEquals(p, aText, aCheck - p) do begin
				Inc(p);
      end;
			AppendTokenText(aText, p - aText);
			if p < aCheck then begin
				aCheck := p
      end
			else begin
				aCheck := aText;
      end;
		end;
	end;
	raise Exception.CreateFmt(SimpleXmlError22, [aText, FCurLine, FCurPos]);
end;

procedure TXmlSource.AppendTokenChar(aChar: Char);
begin
	FToken.AppendChar(aChar);
end;

procedure TXmlSource.AppendTokenText(aText: PChar; aCount: Integer);
begin
	FToken.AppendText(aText, aCount)
end;

procedure TXmlSource.DropToken;
begin
	Dec(FTokenStackTop);
	if FTokenStackTop >= 0 then begin
		FToken := FTokenStack[FTokenStackTop]
  end
	else begin
		FToken := nil
  end;
end;

constructor TXmlSource.Create;
begin
	inherited Create;
	FTokenStackTop := -1;
end;

destructor TXmlSource.Destroy;
var
	i: Integer;
begin
	for i := 0 to Length(FTokenStack) - 1 do begin
		FTokenStack[i].Free;
  end;
	inherited;
end;

{ TXmlToken }

procedure TXmlToken.AppendChar(aChar: Char);
var
	aSaveLength: Integer;
begin
	if FValuePtr >= FValueEnd then begin
		aSaveLength := FValuePtr - FValueStart;
		SetLength(FValueBuf, aSaveLength + 1);
		FValueStart := PChar(FValueBuf);
		FValuePtr := FValueStart + aSaveLength;
		FValueEnd := FValueStart + System.Length(FValueBuf);
	end;
	FValuePtr^ := aChar;
	Inc(FValuePtr);
end;

procedure TXmlToken.AppendText(aText: PChar; aCount: Integer);
var
	aSaveLength: Integer;
begin
	if (FValuePtr + aCount) > FValueEnd then begin
		aSaveLength := FValuePtr - FValueStart;
		SetLength(FValueBuf, aSaveLength + aCount);
		FValueStart := PChar(FValueBuf);
		FValuePtr := FValueStart + aSaveLength;
		FValueEnd := FValueStart + System.Length(FValueBuf);
	end;
	Move(aText^, FValuePtr^, aCount*sizeof(Char));
	Inc(FValuePtr, aCount);
end;

procedure TXmlToken.Clear;
begin
	FValuePtr := FValueStart;
end;

constructor TXmlToken.Create;
begin
	inherited Create;
	SetLength(FValueBuf, 32);
	FValueStart := PChar(FValueBuf);
	FValuePtr := FValueStart;
	FValueEnd := FValueStart + 32;
end;

function TXmlToken.Length: Integer;
begin
	Result := FValuePtr - FValueStart;
end;

function AnsiToUnicode(c: AnsiChar): WideChar;
begin
	MultiByteToWideChar(CP_ACP, 0, @c, 1, @Result, 1);
end;

{ TAnsiStreamXmlSource }

constructor TAnsiStreamXmlSource.Create(aStream: TStream; aBufSize: Integer);
var
	aSize: Integer;
begin
	inherited Create;
	FStream := aStream;
	FBufSize := aBufSize;
	FBufStart := AllocMem(aBufSize);
	FBufPtr := FBufStart;
	FBufEnd := FBufStart;
	FSize := aStream.Size;
	if FSize = 0 then begin
		CurChar := #0
  end
	else begin
		if FSize < FBufSize then begin
			aSize := FSize
    end
		else begin
			aSize := FBufSize;
    end;
		FStream.ReadBuffer(FBufStart^, aSize);
		FBufEnd := FBufStart + aSize;
		FBufPtr := FBufStart;
		Dec(FSize, aSize);
		CurChar := Char(FBufPtr^);
	end
end;

destructor TAnsiStreamXmlSource.Destroy;
begin
	FreeMem(FBufStart);
	inherited;
end;

function TAnsiStreamXmlSource.EOF: Boolean;
begin
	Result := (FBufPtr = FBufEnd) and (FSize = 0)
end;

function TAnsiStreamXmlSource.DoNext: Boolean;
var
	aSize: Integer; 
begin
	if FBufPtr < FBufEnd then begin
		Inc(FBufPtr);
  end;
	if FBufPtr = FBufEnd then begin
		if FSize = 0 then begin
			Result := False;
			CurChar := #0;
		end
		else begin
			if FSize < FBufSize then begin
				aSize := FSize
      end
			else begin
				aSize := FBufSize;
      end;
			FStream.ReadBuffer(FBufStart^, aSize);
			FBufEnd := FBufStart + aSize;
			FBufPtr := FBufStart;
			Dec(FSize, aSize);
			Result := True;
			CurChar := Char(FBufPtr^);
		end
  end
	else begin
		Result := True;
		CurChar := Char(FBufPtr^);
	end;
end;

{ TStreamBinaryXmlReader }

constructor TStreamBinaryXmlReader.Create(aStream: TStream; aBufSize: Integer);
begin
	inherited Create;
	FStream := aStream;
	FRestSize := aStream.Size - aStream.Position;
	FBufSize := aBufSize;
	FBufStart := AllocMem(aBufSize);
	FBufEnd := FBufStart;
	FBufPtr := FBufEnd;
	Read(FOptions, sizeof(FOptions));
end;

destructor TStreamBinaryXmlReader.Destroy;
begin
	FreeMem(FBufStart);
	inherited;
end;

procedure TStreamBinaryXmlReader.Read(var aBuf; aSize: Integer);
var
	aBufRest: Integer;
	aDst: PAnsiChar;
	aBufSize: Integer;
begin
	if aSize > FRestSize then begin
		raise Exception.Create(SSimpleXmlError23);
  end;

	aBufRest := FBufEnd - FBufPtr;
	if aSize <= aBufRest then begin
		Move(FBufPtr^, aBuf, aSize);
		Inc(FBufPtr, aSize);
		Dec(FRestSize, aSize);
	end
	else begin
		aDst := @aBuf;
		Move(FBufPtr^, aDst^, aBufRest);
		Inc(aDst, aBufRest);
		FStream.ReadBuffer(aDst^, aSize - aBufRest);
		Dec(FRestSize, aSize);

		if FRestSize < FBufSize then begin
			aBufSize := FRestSize
    end
		else begin
			aBufSize := FBufSize;
    end;
		FBufPtr := FBufStart;
		FBufEnd := FBufStart + aBufSize;
		if aBufSize > 0 then begin
			FStream.ReadBuffer(FBufStart^, aBufSize);
    end;
	end;
end;

{ TRawByteStringBinaryXmlReader }

constructor TRawByteStringBinaryXmlReader.Create(const aStr: RawByteString);
var
	aSig: array [1..BinXmlSignatureSize] of Byte;
begin
	inherited Create;
	FString := aStr;
	FRestSize := Length(aStr);
  if FRestSize > 0 then begin
  	FPtr := @FString[1];
  end;
	Read(aSig, BinXmlSignatureSize);
	Read(FOptions, sizeof(FOptions));
end;

procedure TRawByteStringBinaryXmlReader.Read(var aBuf; aSize: Integer);
begin
	if aSize > FRestSize then begin
		raise Exception.Create(SSimpleXmlError23);
  end;
	Move(FPtr^, aBuf, aSize);
	Inc(FPtr, aSize);
	Dec(FRestSize, aSize);
end;

{ TBinXmlReader }

function TBinaryXmlReader.ReadAnsiString: AnsiString;
var
	aLength: LongInt;
begin
	aLength := ReadLongint;
	if aLength = 0 then
		Result := ''
	else begin
		SetLength(Result, aLength);
		Read(Result[1], aLength);
	end
end;

function TBinaryXmlReader.ReadLongint: Longint;
var
	b: Byte;
begin
	Result := 0;
	Read(Result, 1);
	if Result >= $80 then
		if Result = $FF then
			Read(Result, sizeof(Result))
		else begin
			Read(b, 1);
			Result := (Result and $7F) shl 8 or b;
		end
end;

procedure TBinaryXmlReader.ReadVariant(var v: TVarData);
var
	aDataType: Word;
	aSize: Longint;
	p: Pointer;
begin
	VarClear(Variant(v));
	aDataType := ReadLongint;
	case aDataType of
		varEmpty: ;
		varNull: ;
		varSmallint:
			Read(v.VSmallint, sizeof(SmallInt));
		varInteger:
			Read(v.VInteger, sizeof(Integer));
		varSingle:
			Read(v.VSingle, sizeof(Single));
		varDouble:
			Read(v.VDouble, sizeof(Double));
		varCurrency:
			Read(v.VCurrency, sizeof(Currency));
		varDate:
			Read(v.VDate, sizeof(TDateTime));
		varOleStr:
			Variant(v) := ReadUnicodeString;
		varBoolean:
			Read(v.VBoolean, sizeof(WordBool));
		varShortInt:
			Read(v.VShortInt, sizeof(ShortInt));
		varByte:
			Read(v.VByte, sizeof(Byte));
		varWord:
			Read(v.VWord, sizeof(Word));
		varLongWord:
			Read(v.VLongWord, sizeof(LongWord));
		varInt64:
			Read(v.VInt64, sizeof(Int64));
		varString:
			Variant(v) := ReadAnsiString;
		varArray + varByte:
			begin
				aSize := ReadLongint;
				Variant(v) := VarArrayCreate([0, aSize - 1], varByte);
				p := VarArrayLock(Variant(v));
				try
					Read(p^, aSize);
				finally
					VarArrayUnlock(Variant(v))
				end
			end;
		else
			raise Exception.Create(SSimpleXmlError24);
	end;
	v.VType := aDataType;
end;

function TBinaryXmlReader.ReadUnicodeString: UnicodeString;
var
	aLength: LongInt;
begin
	aLength := ReadLongint;
	if aLength = 0 then begin
		Result := ''
  end
	else begin
		SetLength(Result, aLength);
		Read(Result[1], aLength*sizeof(WideChar));
	end
end;

function TBinaryXmlReader.ReadXmlString: String;
begin
	if (FOptions and BINXML_USE_WIDE_CHARS) <> 0 then begin
		Result := String(ReadUnicodeString)
  end
	else begin
		Result := String(ReadAnsiString)
  end;
end;

{ TStmXmlWriter }

constructor TStreamBinrayXmlWriter.Create(aStream: TStream; anOptions: LongWord;
  aBufSize: Integer);
begin
	inherited Create;
	FStream := aStream;
	FOptions := anOptions;
	FBufSize := aBufSize;
	FBufStart := AllocMem(aBufSize);
	FBufEnd := FBufStart + aBufSize;
	FBufPtr := FBufStart;
	Write(BinXmlSignature[1], BinXmlSignatureSize);
	Write(FOptions, sizeof(FOptions));
end;

destructor TStreamBinrayXmlWriter.Destroy;
begin
	if FBufPtr > FBufStart then
		FStream.WriteBuffer(FBufStart^, FBufPtr - FBufStart);
	FreeMem(FBufStart);
	inherited;
end;

procedure TStreamBinrayXmlWriter.Write(const aBuf; aSize: Integer);
var
	aBufRest: Integer;
begin
	aBufRest := FBufEnd - FBufPtr;
	if aSize <= aBufRest then begin
		Move(aBuf, FBufPtr^, aSize);
		Inc(FBufPtr, aSize);
	end
	else begin
		if FBufPtr > FBufStart then begin
			FStream.WriteBuffer(FBufStart^, FBufPtr - FBufStart);
			FBufPtr := FBufStart;
		end;
		FStream.WriteBuffer(aBuf, aSize);
	end
end;

{ TStrXmlWriter }

constructor TRawByteStringBinaryXmlWriter.Create(anOptions: LongWord; aBufSize: Integer);
begin
	inherited Create;
	FData := '';
	FOptions := anOptions;
	FBufSize := aBufSize;
	FBufStart := AllocMem(aBufSize);
	FBufEnd := FBufStart + aBufSize;
	FBufPtr := FBufStart;
	Write(BinXmlSignature[1], BinXmlSignatureSize);
	Write(FOptions, sizeof(FOptions));
end;

destructor TRawByteStringBinaryXmlWriter.Destroy;
begin
	FreeMem(FBufStart);
	inherited;
end;

procedure TRawByteStringBinaryXmlWriter.FlushBuf;
var
	aPrevSize: Integer;
	aSize: Integer;
begin
	aPrevSize := Length(FData);
	aSize := FBufPtr - FBufStart;
	SetLength(FData, aPrevSize + aSize);
	Move(FBufStart^, FData[aPrevSize + 1], aSize);
	FBufPtr := FBufStart;
end;

procedure TRawByteStringBinaryXmlWriter.Write(const aBuf; aSize: Integer);
var
	aBufRest: Integer;
	aPrevSize: Integer;
	aBufSize: Integer;
begin
	aBufRest := FBufEnd - FBufPtr;
	if aSize <= aBufRest then begin
		Move(aBuf, FBufPtr^, aSize);
		Inc(FBufPtr, aSize);
	end
	else begin
		aPrevSize := Length(FData);
		aBufSize := FBufPtr - FBufStart;
		SetLength(FData, aPrevSize + aBufSize + aSize);
		if aBufSize > 0 then
			Move(FBufStart^, FData[aPrevSize + 1], aBufSize);
		Move(aBuf, FData[aPrevSize + aBufSize + 1], aSize);
		FBufPtr := FBufStart;
	end
end;

{ TBinXmlWriter }

procedure TBinaryXmlWriter.WriteAnsiString(const aValue: AnsiString);
var
	aLength: LongInt;
begin
	aLength := Length(aValue);
	WriteLongint(aLength);
	if aLength > 0 then begin
		Write(aValue[1], aLength);
  end;
end;

procedure TBinaryXmlWriter.WriteLongint(aValue: Longint);
var
	b: array [0..1] of Byte;
begin
	if aValue < 0 then begin
		b[0] := $FF;
		Write(b[0], 1);
		Write(aValue, SizeOf(aValue));
	end
	else if aValue < $80 then begin
		Write(aValue, 1)
  end
	else if aValue <= $7EFF then begin
		b[0] := (aValue shr 8) or $80;
		b[1] := aValue and $FF;
		Write(b, 2);
	end
	else begin
		b[0] := $FF;
		Write(b[0], 1);
		Write(aValue, SizeOf(aValue));
	end;
end;

procedure TBinaryXmlWriter.WriteVariant(const v: TVarData);
var
	aSize: Integer;
	p: Pointer;
begin
	WriteLongint(v.VType);
	case v.VType of
		varEmpty: ;
		varNull: ;
		varSmallint:
			Write(v.VSmallint, sizeof(SmallInt));
		varInteger:
			Write(v.VInteger, sizeof(Integer));
		varSingle:
			Write(v.VSingle, sizeof(Single));
		varDouble:
			Write(v.VDouble, sizeof(Double));
		varCurrency:
			Write(v.VCurrency, sizeof(Currency));
		varDate:
			Write(v.VDate, sizeof(TDateTime));
		varOleStr:
			WriteUnicodeString(Variant(v));
		varBoolean:
			Write(v.VBoolean, sizeof(WordBool));
		varShortInt:
			Write(v.VShortInt, sizeof(ShortInt));
		varByte:
			Write(v.VByte, sizeof(Byte));
		varWord:
			Write(v.VWord, sizeof(Word));
		varLongWord:
			Write(v.VLongWord, sizeof(LongWord));
		varInt64:
			Write(v.VInt64, sizeof(Int64));
		varString:
			WriteAnsiString(AnsiString(Variant(v)));
		varArray + varByte:
			begin
				aSize := VarArrayHighBound(Variant(v), 1) - VarArrayLowBound(Variant(v), 1) + 1;
				WriteLongint(aSize);
				p := VarArrayLock(Variant(v));
				try
					Write(p^, aSize);
				finally
					VarArrayUnlock(Variant(v))
				end
			end;
		else
			raise Exception.Create(SSimpleXmlError25);
	end;
end;

procedure TBinaryXmlWriter.WriteUnicodeString(const aValue: UnicodeString);
var
	aLength: LongInt;
begin
	aLength := Length(aValue);
	WriteLongint(aLength);
	if aLength > 0 then begin
		Write(aValue[1], aLength*sizeof(WideChar));
  end;
end;


procedure TBinaryXmlWriter.WriteXmlString(const aValue: String);
begin
	if (FOptions and BINXML_USE_WIDE_CHARS) <> 0 then begin
		WriteUnicodeString(UnicodeString(aValue))
  end
	else begin
		WriteAnsiString(AnsiString(aValue))
  end;
end;

var
	DefaultNameTableImpl: TXmlNameTable = nil;

function CreateXmlElement(const aName: String; const aNameTable: IXmlNameTable): IXmlElement;
var
	aNameTableImpl: TXmlNameTable;
begin
	if Assigned(aNameTable) then
		aNameTableImpl := aNameTable.GetObject as TXmlNameTable
	else
		aNameTableImpl := DefaultNameTableImpl;
	Result := TXmlElement.Create(aNameTableImpl, aNameTableImpl.GetID(aName));
end;

function CreateXmlNodeList: IXmlNodeList;
begin
  Result := TXmlNodeList.Create(nil);
end;

function CreateXmlDocument(
	const aRootElementName: String;
	const aVersion: String;
	const anEncoding: String;
	const aNames: IXmlNameTable): IXmlDocument;
var
	aNameTable: TXmlNameTable;
	s: String;
begin
	if Assigned(aNames) then begin
		aNameTable := aNames.GetObject as TXmlNameTable
  end
	else begin
		aNameTable := DefaultNameTableImpl;
  end;
	if anEncoding = '' then begin
		s := DefaultEncoding
  end
	else begin
		s := anEncoding;
  end;
	Result := TXmlDocument.Create(aNameTable);
	if aRootElementName <> '' then begin
		Result.NewDocument(aVersion, anEncoding, aRootElementName);
  end;
end;




function LoadXmlDocumentFromXml(const anXml: String): IXmlDocument;
begin
	Result := TXmlDocument.Create(DefaultNameTableImpl);
	Result.LoadXML(anXml);
end;




function LoadXmlDocumentFromBinaryXML(const aBinaryXml: RawByteString): IXmlDocument;
begin
	Result := TXmlDocument.Create(DefaultNameTableImpl);
	Result.LoadBinaryXML(aBinaryXml);
end;




function LoadXmlDocument(aStream: TStream): IXmlDocument;
begin
	Result := TXmlDocument.Create(DefaultNameTableImpl);
	Result.Load(aStream);
end;




function LoadXmlDocument(const aFileName: String): IXmlDocument; overload;
begin
	Result := TXmlDocument.Create(DefaultNameTableImpl);
	Result.Load(aFileName);
end;




function LoadXmlDocument(aResType, aResName: PChar): IXmlDocument; overload;
begin
	Result := TXmlDocument.Create(DefaultNameTableImpl);
	Result.LoadResource(aResType, aResName);
end;




function AppendChildNodeFromXml(const aParentNode: IXmlNode; const anXml: String): IXmlNode;
begin
	Result := LoadXmlDocumentFromXml(anXml).DocumentElement.CloneNode(true);
	aParentNode.AppendChild(Result);
end;




initialization
	DefaultNameTableImpl := TXmlNameTable.Create(4096);
	DefaultNameTable := DefaultNameTableImpl;
finalization
	DefaultNameTable := nil;
	DefaultNameTableImpl := nil;
end.
