unit KeyRes;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TKeyResultForm = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    lKey: TEdit;
    lPwd: TEdit;
    bOK: TButton;
    bCancel: TButton;
    bHelp: TButton;
    Label3: TLabel;
    lSum: TEdit;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  KeyResultForm: TKeyResultForm;

implementation

{$R *.DFM}


end.
