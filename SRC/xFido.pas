unit xFido;

{$I DEFINE.INC}


interface uses xBase, CommCtrl, Windows;

type
  TNodeType = (fntUnk, fntZone, fntRegion, fntNet, fntHub, fntNode, fntPoint);
  TPktFileType = (pftNone, pftFTS1, pftFSC39, pftFSC45, pftP2K, pftUnknown, pftOpenErr, pftReadErr);

  POutStatus = ^TOutStatus;
  TOutStatus = (osError, osBusy, os_CrashMail, os_DirectMail, osNormalMail, osHoldMail,
                os_Crash, os_Direct, osNormal, osHold, osHReq,
                osRequest, osNone);

  PKillAction = ^TKillAction;
  TKillAction = (kaBsoNothingAfter, kaBsoKillAfter, kaBsoTruncateAfter, kaFbKillAfter, kaFbMoveAfter);

  TOutAttType = (oatUnk, oatBSO, oatFileBox);
  TOutAttTypeSet = set of TOutAttType;

  TInboundPutKind = (ipkUnk, ipkQueue, ipkOverwrite);

{-- P2K }

const
  P2K_FAttribute_IsKillSent      = $01; // 1 *
  P2K_FAttribute_IsFileAttached  = $02; // 2
  P2K_FAttribute_IsFileRequest   = $04; // 3
  P2K_FAttribute_IsTruncFile     = $08; // 4 *
  P2K_FAttribute_IsKillFile      = $10; // 5 *
  P2K_SENDMASK_F                 = $19;

  P2K_RAttribute_IsCrash         = $01;
  P2K_RAttribute_IsHold          = $02;
  P2K_RAttribute_IsDirect        = $04;
  P2K_RAttribute_IsExclusive     = $08;
  P2K_RAttribute_IsImmediate     = $10;
  P2K_SENDMASK_R                 = $00;

  P2K_GAttribute_IsLocal         = $01; // 1 *
  P2K_GAttribute_IsSent          = $02; // 2 *
  P2K_GAttribute_IsPrivate       = $04; // 3
  P2K_GAttribute_IsOrphan        = $08; // 4 *
  P2K_SENDMASK_G                 = $0B;

type
  TP2K_NetworkAddress = packed record
    Zone,
    Net,
    Node,
    Point: Word;
  end;

  TType2000HeaderV5 = packed record
    MainHeaderLen,
    SubHeaderLen: Word;
    OrigAddr: TP2K_NetworkAddress;
    OrigDomain: string[30];
    DestAddr: TP2K_NetworkAddress;
    DestDomain: string[30];
    Password: string[8];
    ProductName: string[30];
    PktVersionMajor,
    PktVersionMinor: Word;
  end;

  TPakd2000MsgHeadrV5 = packed record
    OrigAddr,
    DestAddr,
    WrittenAddr: TP2K_NetworkAddress;
    Year: Word;
    Month,
    Day,
    Hour,
    Min,
    Sec,
    Sec100,
    FAttribute,
    RAttribute,
    GAttribute: Byte;
    SeenBys,
    Paths: Word;
    TextBytes: Integer;
  end;

{-- FTS1}

  TFTS1PktHdr = packed record       // FTS-0001 Packet
    OrigNode,                       // originating node
    DestNode,                       // destination node
    Year,                           // 0..99  when packet was created
    Month,                          // 0..11  when packet was created
    Day,                            // 1..31  when packet was created
    Hour,                           // 0..23  when packet was created
    Minute,                         // 0..59  when packet was created
    Second,                         // 0..59  when packet was created
    Rate,                           // destination's baud rate
    Version,                        // packet version, must be 2
    OrigNet,                        // originating network number
    DestNet: Word;                  // destination network number
    Product,                        // product type
    Serial: Byte;                   // serial number (some systems)
    Password: array[0..7] of Char;  // session/pickup password
    OrigZone,                       // originating zone
    DestZone: Word;                 // Destination zone
    B_fill2: array[0..15] of Char;
    B_fill3: Integer;
  end;

  TFSC45PktHdr = packed record      // FSC-0045 (2.2) packet
    OrigNode,                       // originating node
    DestNode,                       // destination node
    OrigPoint,                      // originating point
    DestPoint: Word;                // destination point
    B_fill1: array[0..7] of Byte;   // Unused, must be zero
    SubVersion,                     // packet subversion, must be 2
    Version,                        // packet version, must be 2
    OrigNet,                        // originating network number
    DestNet: Word;                  // destination network number
    Product,                        // product type
    Serial: Byte;                   // serial number (some systems)
    Password: array[0..7] of Char;  // session/pickup password
    OrigZone,                       // originating zone
    DestZone: Word;                 // Destination zone
    OrigDomain,                     // originating domain
    DestDomain: array[0..7] of Char;// destination domain
    B_fill3: Integer;
  end;

  TFSC39PktHdr = packed record      // FSC-0039 packet type
    OrigNode,                       // originating node
    DestNode,                       // destination node
    Year,                           // 0..99  when packet was created
    Month,                          // 0..11  when packet was created
    Day,                            // 1..31  when packet was created
    Hour,                           // 0..23  when packet was created
    Minute,                         // 0..59  when packet was created
    Second,                         // 0..59  when packet was created
    Rate,                           // destination's baud rate
    Version,                        // packet version, must be 2
    OrigNet,                        // originating network number
    DestNet: Word;                  // destination network number
    ProductLow,                     // FTSC product type (low byte)
    ProdRevLow: Byte;               // product rev (low byte)
    Password: array[0..7] of Char;  // session/pickup password
    OrigZoneIgnore,                 // Zone info from other software
    DestZoneIgnore: Word;           // Zone info from other software
    Reserved: Word;                 // Spare Change, undefined
    CapValid: Word;                 // CapWord with bytes swapped.
    ProductHi,                      // FTSC product type (high byte)
    ProdRevHi: Byte;                // product rev (hi byte)
    CapWord,                        // Capability word
    OrigZone,                       // originating zone
    DestZone,                       // Destination zone
    OrigPoint,                      // originating point
    DestPoint: Word;                // destination point
    ProdData: Integer;              // Product-specific data
  end;

  PTeLinkBlk = ^TTeLinkBlk;
  TTeLinkBlk = packed record
    FileLen: DWORD;
    FileTime,
    FileDate: Word;
    FileName: array[0..15] of Byte;
    NullByte: Byte;
    ProgramName: array[0..15] of Byte;
    CRCMode: Byte;
    Fill: array[0..85] of Byte;
  end;

  TXmodemBlk = packed record
    Header,
    BlockNumA,
    BlockNumB: Byte;
    Data: array[0..127] of Byte;
    CrcHi,
    CrcLo: Byte;
  end;

  TFTS1BlkType = (
    btUndefined,
    btEmpty,
    btNone,
    btErr,
    btTeLink,
    btData,
    btEOT,
    btTSync
  );


  TEMSISeq = (es_INQ, es_REQ, es_CLI, es_HBT, es_DAT, es_ACK, es_NAK,
              es_IRQ, es_IIR, es_ICI, es_ISI, es_ISM, es_CHT, es_TCH,
              es_TZP, es_PZT, es_None, es_DatError);

// TCallingOption   = (coNPU, coPUP, coPUA, coNone);
// TAnsweringOption = (aoHAT, aoHTX, aoHRQ, aoNone);

  TTransportType = (ttUnknown, ttInvalid, ttDialup, ttIP);

  TEMSIAddonType = (
    eaIDENT,
    eaMOH,
    eaTRX,
    eaTRAF,
    eaCustom
  );

  TEMSILinkCode = (
        el8N1,     // Communication parameter
//    Calling system options
        elPUA,     // Pickup mail for all presented addresses.
        elPUP,     // Pickup mail for primary address only.
        elNPU,     // No mail pickup desired.
//    Answering system options:
        elHAT,     // Hold ALL traffic.
        elHXT,     // Hold compressed mail traffic.
        elHRQ,     // Hold file requests (not processed at this time).
        elNone
  );
  TEMSILinkCodes = set of TEMSILinkCode;

  TEMSICapability = (
        ecBND,     // BinkP
        ecHYD,     // Hydra.
        ecJAN,     // Janus.
        ecKER,     // Kermit.
        ecDZA,     // DirectZAP (Zmodem variant).
        ecZAP,     // ZedZap (Zmodem variant).
        ecZMO,     // Zmodem w/1,024 byte data packets.
        ecYMO,     // YModem
        ecNCP,     // No compatible protocols (failure).

        ecNRQ,     // No file requests accepted by this system.
        ecARC,     // ARCmail 0.60-capable, as defined by the FTSC.
        ecXMA,     // Supports other forms of compressed mail.
        ecHFR,     // Support hold file requests
        ecFNC,     // MS-DOS filename conversion.
        ecNone
  );
  TEMSICapabilities = set of TEMSICapability;

  TEMSIColl = class(TStringColl)
    property FingerPrint     : string index 0 read GetString;
    property AddressList     : string index 1 read GetString;
    property Password        : string index 2 read GetString;
    property LinkCodes       : string index 3 read GetString;
    property Compatibility   : string index 4 read GetString;
    property MlrProductCode  : string index 5 read GetString;
    property MlrName         : string index 6 read GetString;
    property MlrVersion      : string index 7 read GetString;
    property MlrSerialNo     : string index 8 read GetString;
  end;

  PFidoAddress = ^TFidoAddress;
  TFidoAddress = record
  case Integer of
    0 : (Zone, Net, Node, Point: Integer;);
    1 : (arr: array[1..4] of Integer;)
  end;

  TFidoAddrColl = class(TSortedColl)
    function GetString: string;
    function Compare(Key1, Key2: Pointer): Integer; override;
    procedure FreeItem(Item: Pointer); override;
    function KeyOf(Item: Pointer): Pointer; override;
    procedure PutItem(Stream: TxStream; Item: Pointer); override;
    function GetItem(Stream: TxStream): Pointer; override;
    procedure SetAddress(Index: Integer; const Value: TFidoAddress);
    function GetAddress(Index: Integer): TFidoAddress;
    property Addresses[Index: Integer]: TFidoAddress read GetAddress write SetAddress; default;
    function Crc32Item(Item: Pointer; Crc32: DWORD): DWORD; override;
    procedure Add(const A: TFidoAddress);
    procedure Ins(const A: TFidoAddress);
  end;

  TNodePrefixFlag = (nfUndef, nfNormal, nfPoint, nfHub, nfNet, nfZone, nfPvt, nfHold, nfDown, nfOver, nfUrec);

const
  cNodePrefixFlag: array[TNodePrefixFlag] of string = ('?', 'Node', 'Point', 'Hub', 'Host', 'Zone', 'Pvt', 'Hold', 'Down', '??', '???');

type
  TAdvNodeData = class(TAdvCpOnlyObject)
    Flags,
    Phone,
    IPAddr: string;
    function Copy: Pointer; override;
  end;

  TAdvNodeExtData = class(TAdvCpOnlyObject)
    Opts, Cmd: string;
    function Copy: Pointer; override;
  end;

  TAdvNode = class(TAdvCpOnlyObject)
    PrefixFlag: TNodePrefixFlag;
    Speed: Integer;
    Station,
    Sysop,
    Location: String;
    Addr: TFidoAddress;
    DialupData, IPData: TColl;
    Ext: TAdvNodeExtData;
    function Copy: Pointer; override;
    destructor Destroy; override;
  end;

  TFidoNode = class
  public
    PrefixFlag: TNodePrefixFlag;
    TreeItem: HTreeItem;
    HasPoints: Boolean;
    Addr: TFidoAddress;
    Hub,
    Speed: Integer;
    Station,
    Sysop,
    Phone,
    Flags,
    Location: String;
    function Copy: TFidoNode;
    procedure FillNodelist(AAddr: TFidoAddress; const AStr: ShortString; APrefixFlag: TNodePrefixFlag);
    procedure FillStream(AZone, ANet: Integer; S: TxStream);
    procedure   _Store(S: TxStream);
    destructor  Destroy; override;
    constructor Init;
  end;

  TFidoNodeColl = class(TSortedColl)
    function Compare(Key1, Key2: Pointer): Integer; override;
    function KeyOf(Item: Pointer): Pointer; override;
  end;

  TFidoNet = class(TFidoNodeColl)
    Zone, Net, Position: Integer;
  end;

  PFidoZoneData = ^TFidoZoneData;
  TFidoZoneData = packed record
     Zone, Net,
     First,
     Pos: Integer;
  end;

  TFidoZone = class
    d: TFidoZoneData;
  end;


  Ta4s = array[1..4] of string;
  TFSC62Quant = 0..47;

  TFSC62Time = set of TFSC62Quant;

  TOvrData = class
    PhoneDirect: string;
    Flags: string;
    PhoneNodelist: TFidoAddress;
  end;

  T_Minute = 0..59;
  T_Hour   = 0..23;
  T_Day    = 0..30;
  T_Month  = 0..11;
  T_Dow    = 0..06;

  TMinuteSet = set of T_Minute;
  THourSet   = set of T_Hour;
  TDaySet    = set of T_Day;
  TMonthSet  = set of T_Month;
  TDowsSet   = set of T_Dow;

  TCronRec = packed record
    Minutes : TMinuteSet;
    Hours   : THourSet;
    Days    : TDaySet;
    Months  : TMonthSet;
    Dows    : TDowsSet;
  end;

  TCronRecArr = packed array[0..(MaxInt div SizeOf(TCronRec))-1] of TCronRec;
  PCronRecArr = ^TCronRecArr;

  TCronRecord = class
    p: PCronRecArr;
    Count: Integer;
    IsPermanent: Boolean;
    IsUTC: Boolean;
    destructor Destroy; override;
  end;

  TOvrItemTyp = (oiAddress, oiAddressMask, oiFlag, oiInvFlag, oiPhoneNum, oiIPNum, oiIPSym, oiUnknown);

  EMSIOpt = set of (crc32, varlen, error);

const
  MaxModemCmdIdx = 5;

  EMSI_Seq : array[TEMSISeq] of
  record
    S: string[3];
    O: EMSIOpt;
  end = (
  (S:'INQ';O:[]),
  (S:'REQ';O:[]),
  (S:'CLI';O:[]),
  (S:'HBT';O:[]),
  (S:'DAT';O:[varlen]),
  (S:'ACK';O:[]),
  (S:'NAK';O:[]),
  (S:'IRQ';O:[]),
  (S:'IIR';O:[]),
  (S:'ICI';O:[crc32,varlen]),
  (S:'ISI';O:[crc32,varlen]),
  (S:'ISM';O:[crc32,varlen]),
  (S:'CHT';O:[]),
  (S:'TCH';O:[]),
  (S:'tzp';O:[error]),
  (S:'pzt';O:[error]),
  (S:'';O:[error]),
  (S:'';O:[error])

 );

  SEMSICapabilities  : array[TEMSICapability] of string =
    ('BND', 'HYD', 'JAN', 'KER', 'DZA', 'ZAP', 'ZMO', 'YMO', 'NCP',
    'NRQ','ARC','XMA', 'HFR', 'FNC','');
  SEMSILinkCodes : array[TEMSILinkCode] of string = ('8N1', 'PUA', 'PUP', 'NPU', 'HAT', 'HXT', 'HRQ', '');
  SEMSIAddons : array[TEMSIAddonType] of string =
    ('IDENT', 'MOH#', 'TRX#', 'TRAF', '');

const
  MaxProductCode = $10A;
  SProdCodes : array[0..MaxProductCode] of string = (
    'Fido',                          {0000, MS-DOS, Packer/mailer, Tom_Jennings}
    'Rover',                         {0001, MS-DOS, Packer/mailer, Bob_Hartman}
    'SEAdog',                        {0002, MS-DOS, Packer/mailer, Thom_Henderson}
    'WinDog',                        {0003, MS-DOS, Mailer, Solar_Wind_Computing}
    'Slick-150',                     {0004, HP-150, Packer/mailer, Jerry_Bain}
    'Opus',                          {0005, MS-DOS, Packer/mailer, Doug_Boone}
    'Dutchie',                       {0006, MS-DOS, Packer/mailer, Henk_Wevers}
    'WPL_Library',                   {0007, Amiga, Mailer, Russell_McOrmand}
    'Tabby',                         {0008, Macintosh, Packer/mailer, Michael_Connick}
    'SWMail',                        {0009, OS/2, Mailer, Solar_Wind_Computing}
    'Wolf-68k',                      {000A, CPM-68k, Packer/mailer, Robert_Heller}
    'QMM',                           {000B, QNX, Packer/mailer, Rick_Duff}
    'FrontDoor',                     {000C, MS-DOS, Packer/mailer, Joaquim_Homrighausen}
    'GOmail',                        {000D, MS-DOS, Packer, Scott_Green}
    'FFGate',                        {000E, MS-DOS, Packer, Ruedi_Kneubuehler}
    'FileMgr',                       {000F, MS-DOS, Packer, Erik_van_Emmerik}
    'FIDZERCP',                      {0010, MS-DOS, Packer, Thorsten_Seidel}
    'MailMan',                       {0011, MS-DOS, Packer, Ron_Bemis}
    'OOPS',                          {0012, MS-DOS, Packer, Tom_Kashuba}
    'GS-Point',                      {0013, Atari_ST, Packer/mailer, Harry_Lee}
    'BGMail',                        {0014, ????, ????, Ray_Gwinn}
    'ComMotion/2',                   {0015, OS/2, Packer/mailer, Michael_Buenter}
    'OurBBS_Fidomailer',             {0016, MS-DOS/Unix/Coherent, Packer/mailer, Brian_Keahl}
    'FidoPcb',                       {0017, MS-DOS, Packer, Matjaz_Koce}
    'WimpLink',                      {0018, Archimedes, Packer/mailer, Remco_de_Vreugd}
    'BinkScan',                      {0019, MS-DOS, Packer, Shawn_Stoddard}
    'D''Bridge',                     {001A, MS-DOS, Packer/mailer, Chris_Irwin}
    'BinkleyTerm',                   {001B, MS-DOS, Mailer, Vince_Perriello}
    'Yankee',                        {001C, MS-DOS, Packer, Randy_Edwards}
    'uuGate',                        {001D, MS-DOS, Packer, Geoff_Watts}
    'Daisy',                         {001E, Apple_][, Packer/mailer, Raymond_&_Ken_Lo}
    'Polar_Bear',                    {001F, ????, Packer/mailer, Kenneth_McLeod}
    'The-Box',                       {0020, MS-DOS/Atari_ST, Packer/mailer, Jac_Kersing/Arjen_Lentz}
    'STARgate/2',                    {0021, OS/2, Packer/mailer, Shawn_Stoddard}
    'TMail',                         {0022, MS-DOS, Packer, Larry_Lewis}
    'TCOMMail',                      {0023, MS-DOS, Packer/mailer, Mike_Ratledge}
    'GIGO',                          {0024, MS-DOS, Packer, Jason_Fesler}
    'RBBSMail',                      {0025, MS-DOS, Packer, Jan_Terpstra}
    'Apple-Netmail',                 {0026, Apple_][, Packer/mailer, Bill_Fenner}
    'Chameleon',                     {0027, Amiga, Mailer, Juergen_Hermann}
    'Majik_Board',                   {0028, MS-DOS, Packer/mailer, Dale_Barnes}
    'QM',                            {0029, MS-DOS, Packer, George_Peace}
    'Point_And_Click',               {002A, Amiga, Packer, Rob_Tillotson}
    'Aurora_Three_Bundler',          {002B, MS-DOS, Packer, Oliver_McDonald}
    'FourDog',                       {002C, MS-DOS, Packer, Shay_Walters}
    'MSG-PACK',                      {002D, MS-DOS, Packer, Tom_Hendricks}
    'AMAX',                          {002E, MS-DOS, Packer, Alan_Applegate}
    'Domain_Communication_System',   {002F, ????, ????, Hal_Duprie}
    'LesRobot',                      {0030, ????, Packer, Lennart_Svensonn}
    'Rose',                          {0031, MS-DOS, Packer/mailer, Glen_Jackson}
    'Paragon',                       {0032, Amiga, Packer/mailer, Jon_Radoff}
    'BinkleyTerm/oMMM/ST',           {0033, Atari_ST, Packer/mailer, Peter_Glasmacher}
    'StarNet',                       {0034, Atari_ST, Mailer, Eric_Drewry}
    'ZzyZx',                         {0035, MS-DOS, Packer, Jason_Steck}
    'QEcho',                         {0036, MS-DOS, Packer, The_QuickBBS_Group}
    'BOOM',                          {0037, MS-DOS, Packer, Andrew_Farmer}
    'PBBS',                          {0038, Amiga, Packer/mailer, Todd_Kover}
    'TrapDoor',                      {0039, Amiga, Mailer, Maximilian_Hantsch}
    'Welmat',                        {003A, Amiga, Mailer, Russell_McOrmand}
    'NetGate',                       {003B, Unix-386, Packer, David_Nugent}
    'Odie',                          {003C, MS-DOS, Mailer, Matt_Farrenkopf}
    'Quick_Gimme',                   {003D, CPM-80/MS-DOS, Packer/mailer, Laeeth_Isaacs}
    'dbLink',                        {003E, MS-DOS, Packer/mailer, Chris_Irwin}
    'TosScan',                       {003F, MS-DOS, Packer, Joaquim_Homrighausen}
    'Beagle',                        {0040, MS-DOS, Mailer, Alexander_Holy}
    'Igor',                          {0041, MS-DOS, Mailer, Harry_Lee}
    'TIMS',                          {0042, MS-DOS, Packer/mailer, Bit_Bucket_Software}
    'Phoenix',                       {0043, MS-DOS, Packer/mailer, International_Telecommunications}
    'FrontDoor_APX',                 {0044, MS-DOS, Packer/mailer, Joaquim_Homrighausen}
    'XRS',                           {0045, MS-DOS, Packer, Mike_Ratledge}
    'Juliet_Mail_System',            {0046, Amiga, Packer, Gregory_Kritsch}
    'Jabberwocky',                   {0047, Macintosh, Packer, Eric_Larson}
    'XST',                           {0048, MS-DOS, Packer, Wayne_Michaels}
    'MailStorm',                     {0049, Amiga, Packer, Russel_Miranda}
    'BIX-Mail',                      {004A, ????, Mailer, Bob_Hartman}
    'IMAIL',                         {004B, MS-DOS, Packer, IMAIL_INC.}
    'FTNGate',                       {004C, MS-DOS, Packer, Jason_Steck}
    'RealMail',                      {004D, MS-DOS, Packer, Taine_Gilliam}
    'Lora-CBIS',                     {004E, MS-DOS, Mailer, Marco_Maccaferri}
    'TDCS',                          {004F, PDP-11, Packer/mailer, Terry_Ebdon}
    'InterMail',                     {0050, MS-DOS, Packer/mailer, Peter_Stewart}
    'RFD',                           {0051, MS-DOS, Packer, Doug_Belkofer}
    'Yuppie!',                       {0052, MS-DOS, Packer, Leo_Moll}
    'EMMA',                          {0053, MS-DOS, Packer, Johan_Zwiekhorst}
    'QBoxMail',                      {0054, QDOS, Packer/mailer, Jan_Bredenbeek}
    'Number_4',                      {0055, MS-DOS, Packer/mailer, Ola_Garstad}
    'Number_5',                      {0056, MS-DOS, Packer/mailer, Ola_Garstad}
    'GSBBS',                         {0057, MS-DOS, Packer, Michelangelo_Jones}
    'Merlin',                        {0058, MS-DOS, Packer/mailer, Mark_Lewis}
    'TPCS',                          {0059, MS-DOS, Packer, Mikael_Kjellstrom}
    'Raid',                          {005A, MS-DOS, Packer, George_Peace}
    'Outpost',                       {005B, MS-DOS, Packer/mailer, Mike_Dailor}
    'Nizze',                         {005C, MS-DOS, Packer, Tomas_Nielsen}
    'Armadillo',                     {005D, Macintosh, Packer, Erik_Sea}
    'rfmail',                        {005E, Unix, Packer/mailer, Per_Lindqvist}
    'Msgtoss',                       {005F, MS-DOS, Packer, Mike_Zakharoff}
    'InfoTex',                       {0060, MS-DOS, Packer/mailer, Jan_Spooren}
    'GEcho',                         {0061, MS-DOS, Packer, Gerard_van_der_Land}
    'CDEhost',                       {0062, MS-DOS, Packer, Dennis_D'Annunzio}
    'Pktize',                        {0063, MS-DOS, Packer, Joaquim_Homrighausen}
    'PC-RAIN',                       {0064, MS-DOS, Packer/mailer, Ray_Hyder}
    'Truffle',                       {0065, MS-DOS/OS2, Mailer, Mike_Rissa}
    'Foozle',                        {0066, Amiga, Packer, Peer_Hasselmeyer}
    'White_Pointer',                 {0067, Macintosh, Packer/mailer, Alastair_Rakine}
    'GateWorks',                     {0068, MS-DOS, Packer, Jamie_Penner}
    'Portal_of_Power',               {0069, MS-DOS, Mailer, Soren_Ager}
    'MacWoof',                       {006A, Macintosh, Packer/mailer, Craig_Vaughan}
    'Mosaic',                        {006B, MS-DOS, Packer, Christopher_King}
    'TPBEcho',                       {006C, MS-DOS, Packer, Gerd_Qualmann}
    'HandyMail',                     {006D, MS-DOS, Packer/mailer, jim_nutt}
    'EchoSmith',                     {006E, MS-DOS, Packer, Noel_Crow}
    'FileHost',                      {006F, MS-DOS, Packer, Mark_Cole}
    'SFTS',                          {0070, MS-DOS, Packer, Bruce_Anderson}
    'Benjamin',                      {0071, MS-DOS, Packer/mailer, Stefan_Graf}
    'RiBBS',                         {0072, OS9_(COCO), Packer/mailer, Ron_Bihler}
    'MP',                            {0073, MS-DOS, Packer, Ivan_Leong}
    'Ping',                          {0074, MS-DOS, Packer, David_Nugent}
    'Door2Europe',                   {0075, MS-DOS, Packer/mailer, Michaela_Schoebel}
    'SWIFT',                         {0076, MS-DOS, Packer/mailer, Hanno_van_der_Maas}
    'WMAIL',                         {0077, MS-DOS, Packer, Silvan_Calarco}
    'RATS',                          {0078, MS-DOS, Packer, Jason_DeCaro}
    'Harry_the_Dirty_Dog',           {0079, OS2, Mailer/packer, George_Edwards}
    'Maximus-CBCS',                  {007A, MS-DOS/OS2, Packer, Scott_Dudley}
    'SwifEcho',                      {007B, MS-DOS, Packer, Dana_Bell}
    'GCChost',                       {007C, Amiga, Packer, Davide_Massarenti}
    'RPX-Mail',                      {007D, MS-DOS, Packer, Joerg_Wirtgen}
    'Tosser',                        {007E, MS-DOS, Packer, Albert_Ng}
    'TCL',                           {007F, MS-DOS, Packer, Ulf_Hedlund}
    'MsgTrack',                      {0080, MS-DOS, Packer, Andrew_Farmer}
    'FMail',                         {0081, MS-DOS, Packer, Folkert_Wijnstra}
    'Scantoss',                      {0082, MS-DOS, Packer, Michael_Matter}
    'Point_Manager',                 {0083, Amiga, Packer, Pino_Aliberti}
    'IMBINK',                        {0084, MS-DOS, Packer, Mike_Hartmann}
    'Simplex',                       {0085, MS-DOS/OS2, Packer, Chris_Laforet}
    'UMTP',                          {0086, MS-DOS, Packer, Byron_Copeland}
    'Indaba',                        {0087, MS-DOS, Packer, Pieter_Muller}
    'Echomail_Engine',               {0088, MS-DOS, Packer, Joe_Jared}
    'DragonMail',                    {0089, OS2, Packer, Patrick_O'Riva}
    'Prox',                          {008A, MS-DOS, Packer, Gerhard_Hoogterp}
    'Tick',                          {008B, MS-DOS/OS2, Packer, Barry_Geller}
    'RA-Echo',                       {008C, MS-DOS, Packer, Roger_Kirchhoff}
    'TrapToss',                      {008D, Amiga, Packer, Maximilian_Hantsch}
    'Babel',                         {008E, MS-DOS/OS2, Packer, Jorgen_Abrahamsen}
    'UMS',                           {008F, Amiga, Packer, Martin_Horneffer}
    'RWMail',                        {0090, MS-DOS, Packer, Remko_Westrik}
    'WildMail',                      {0091, MS-DOS, Packer, Derek_Koopowitz}
    'AlMAIL',                        {0092, MS-DOS, Packer, Alan_Leung}
    'XCS',                           {0093, MS-DOS, Packer, Rudi_Kusters}
    'Fone-Link',                     {0094, MS-DOS, Packer/mailer, Chris_Sloyan}
    'Dogfight',                      {0095, MS-DOS, Packer, Chris_Tyson}
    'Ascan',                         {0096, MS-DOS, Packer, Arjen_van_Loon}
    'FastMail',                      {0097, MS-DOS, Packer, Jan_Berends}
    'DoorMan',                       {0098, MS-DOS, Mailer, Christopher_Dean}
    'PhaedoZap',                     {0099, Atari_ST, Packer, Jeff_Mitchell}
    'SCREAM',                        {009A, MS-DOS, Packer/mailer, Jem_Miller}
    'MoonMail',                      {009B, MS-DOS, Packer/mailer, Hasse_Wigdahl}
    'Backdoor',                      {009C, Sinclair_QL, Packer, Erik_Slagter}
    'MailLink',                      {009D, Archimedes, Packer/mailer, Jan-Jaap_v._d._Geer}
    'Mail_Manager',                  {009E, MS-DOS, Packer, Andreas_Brodowski}
    'Black_Star',                    {009F, Xenix_386, Packer/mailer, Jac_Kersing}
    'Bermuda',                       {00A0, Atari_ST/MS-DOS, Packer, Jac_Kersing}
    'PT',                            {00A1, MS-DOS, Packer/mailer, Jerry_Andrew}
    'UltiMail',                      {00A2, MS-DOS, Mailer, Brett_Floren}
    'GMD',                           {00A3, MS-DOS, Packer, John_Souvestre}
    'FreeMail',                      {00A4, MS-DOS, Packer, Chad_Nelson}
    'Meliora',                       {00A5, MS-DOS, Packer, Erik_van_Riper}
    'Foodo',                         {00A6, CPM-80, Packer/mailer, Ron_Murray}
    'MSBBS',                         {00A7, CPM-80, Packer, Marc_Newman}
    'Boston_BBS',                    {00A8, MS-DOS, Packer/mailer, Tom_Bradford}
    'XenoMail',                      {00A9, MS-DOS, Packer/mailer, Noah_Wood}
    'XenoLink',                      {00AA, Amiga, Packer/mailer, Jonathan_Forbes}
    'ObjectMatrix',                  {00AB, MS-DOS, Packer, Roberto_Ceccarelli}
    'Milquetoast',                   {00AC, Win3/MS-DOS, Mailer, Vince_Perriello}
    'PipBase',                       {00AD, MS-DOS, Packer, Roberto_Piola}
    'EzyMail',                       {00AE, MS-DOS, Packer, Peter_Davies}
    'FastEcho',                      {00AF, MS-DOS, Packer, Tobias_Burchhardt}
    'IOS',                           {00B0, Atari_ST/TT, Packer, Rinaldo_Visscher}
    'Communique',                    {00B1, MS-DOS, Packer, Ian_Harris}
    'PointMail',                     {00B2, MS-DOS, Packer, Michele_Clinco}
    'Harvey''s_Robot',               {00B3, MS-DOS, Packer, Harvey_Parisien}
    '2daPoint',                      {00B4, MS-DOS, Packer, Ron_Pritchett}
    'CommLink',                      {00B5, MS-DOS, Mailer, Steve_Shapiro}
    'fronttoss',                     {00B6, MS-DOS, Packer, Dirk_Astrath}
    'SysopPoint',                    {00B7, MS-DOS, Packer, Rudolf_Heeb}
    'PTMAIL',                        {00B8, MS-DOS, Packer, Arturo_Krogulski}
    'MHS',                           {00B9, MS-DOS/OS2/WINNT, Packer/mailer, Matthias_Hertzog}
    'DLGMail',                       {00BA, Amiga, Packer, Steve_Lewis}
    'GatePrep',                      {00BB, MS-DOS, Packer, Andrew_Allen}
    'Spoint',                        {00BC, MS-DOS, Packer, Conrad_Thompson}
    'TurboMail',                     {00BD, MS-DOS, Packer, B._J._Weschke}
    'FXMAIL',                        {00BE, MS-DOS, Packer, Kenneth_Roach}
    'NextBBS',                       {00BF, MS-DOS, Packer/mailer, Tomas_Hood}
    'EchoToss',                      {00C0, MS-DOS, Packer, Mikel_Beck}
    'SilverBox',                     {00C1, Amiga, Packer, David_Lebel}
    'MBMail',                        {00C2, MS-DOS, Packer, Ruud_Uphoff}
    'SkyFreq',                       {00C3, Amiga, Packer, Luca_Spada}
    'ProMailer',                     {00C4, Amiga, Mailer, Ivan_Pintori}
    'Mega_Mail',                     {00C5, MS-DOS, Packer/mailer, Mirko_Mucko}
    'YaBom',                         {00C6, MS-DOS, Packer, Berin_Lautenbach}
    'TachEcho',                      {00C7, MS-DOS, Packer, Tom_Zacios}
    'XAP',                           {00C8, MS-DOS, Packer, Jeroen_Smulders}
    'EZMAIL',                        {00C9, MS-DOS, Packer, Torben_Paving}
    'Arc-Binkley',                   {00CA, Archimedes, Mailer, Geoff_Riley}
    'Roser',                         {00CB, MS-DOS, Packer, Chan_Kafai}
    'UU2',                           {00CC, MS-DOS, Packer, Dmitri_Zavalishin}
    'NMS',                           {00CD, MS-DOS, Packer/mailer, Michiel_de.Bruijn}
    'BBCSCAN',                       {00CE, Archimedes, Packer/mailer, E._G._Snel}
    'XBBS',                          {00CF, MS-DOS, Packer, Mark_Kimes}
    'LoTek_Vzrul',                   {00D0, Packer/mailer, Kevin_Gates, 1:140/64}
    'Private_Point_Project',         {00D1, MS-DOS, Packer, Oliver_von_Bueren}
    'NoSnail',                       {00D2, MS-DOS, Packer, Eddie_Rowe}
    'SmlNet',                        {00D3, MS-DOS, Packer, Steve_T._Gove}
    'STIR',                          {00D4, MS-DOS, Packer, Paul_Martin}
    'RiscBBS',                       {00D5, Archimedes, Packer, Carl_Declerck}
    'Hercules',                      {00D6, Amiga, Packer/mailer, Andrew_Gray}
    'AMPRGATE',                      {00D7, MS-DOS, Packer/mailer, Mike_Bilow}
    'BinkEMSI',                      {00D8, MS-DOS, Mailer, Tobias_Burchhardt}
    'EditMsg',                       {00D9, MS-DOS, Packer, G._K._Pace}
    'Roof',                          {00DA, Amiga, Packer, Robert_Williamson}
    'QwkPkt',                        {00DB, MS-DOS, Packer, Ross_West}
    'MARISCAN',                      {00DC, MS-DOS, Packer, Mario_Elkati}
    'NewsFlash',                     {00DD, MS-DOS, Packer, Chris_Lueders}
    'Paradise',                      {00DE, MS-DOS, Packer/mailer, Kenneth_Wall}
    'DogMatic-ACB',                  {00DF, N/A, Packer/mailer, Martin_Allard}
    'T-Mail',                        {00E0, MS-DOS, Packer/mailer, Andy_Elkin}
    'JetMail',                       {00E1, Atari_ST/STE/TT, Packer, Daniel_Roesen}
    'MainDoor',                      {00E2, MS-DOS, Packer/mailer, Francisco_Sedano}
    'Starnet_Products',              {00E3, MS-DOS/OS2, Mailer/Packer, Starnet_Software_Development}
    'BMB',                           {00E4, Amiga, Packer, Dentato_Remo}
    'BNP',                           {00E5, MS-DOS, Packer, Nathan_Moschkin}
    'MailMaster',                    {00E6, MS-DOS, Packer/mailer, Gary_Murphy}
    'Mail_Manager_+Plus+',           {00E7, MS-DOS, Packer, Chip_Morrow}
    'BloufGate',                     {00E8, Atari_ST/Unix, Packer, Vincent_Pomey}
    'CrossPoint',                    {00E9, MS-DOS, Packer/mailer, Peter_Mandrella}
    'DeltaEcho',                     {00EA, MS-DOS, Packer, Mikael_Staldal}
    'ALLFIX',                        {00EB, MS-DOS, Packer, Harald_Harms}
    'NetWay',                        {00EC, Archimedes, Mailer, Steve_Haslam}
    'MARSmail',                      {00ED, Atari_ST, Packer, Folkert_val_Heusden}
    'ITRACK',                        {00EE, MS-DOS, Packer, Frank_Prade}
    'GateUtil',                      {00EF, MS-DOS, Packer, Michael_Skurka}
    'Bert',                          {00F0, MS-DOS, Packer/mailer, Arnim_Wiezer}
    'Techno',                        {00F1, MS-DOS, Packer, Patrik_Holmsten}
    'AutoMail',                      {00F2, MS-DOS, Packer, Mats_Wallin}
    'April',                         {00F3, Amiga, Packer, Nick_de_Jong}
    'Amanda',                        {00F4, MS-DOS, Packer, David_Douthitt}
    'NmFwd',                         {00F5, MS-DOS, Packer, Alberto_Pasquale}
    'FileScan',                      {00F6, MS-DOS, Packer, Matthias_Duesterhoeft}
    'FredMail',                      {00F7, MS-DOS, Packer, Michael_Butler}
    'TP_Kom',                        {00F8, MS-DOS, Packer/mailer, Per_Sten}
    'FidoZerb',                      {00F9, MS-DOS, Packer, Ulrich_Schlechte}
    '!!MessageBase',                 {00FA, MS-DOS, Packer/mailer, Holger_Lembke}
    'EMFido',                        {00FB, Amiga, Packer, Gary_Glendown}
    'GS-Toss',                       {00FC, MS-DOS, Packer, Marco_Bungalski}
    'QWKDoor',                       {00FD, Atari_ST, Packer, Christian_Limpach}
    'Mailer',                        {00FE, Any, Packer, No_Author}
    '16-bit_product_id',             {00FF, Any, Packer/Mailer, No_Author}
    'Reservered',                    {0100, None, None, No_Author}
    'The_Brake!',                    {0101, Mailer, John_Gladkih, 2:5051/16}
    'Zeus_BBS',                      {0102, Amiga, Mailer, Alex_May}
    'XenoPhobe-Mailer',              {0103, Msdos/Windows/OS2/Linux, Mailer, Peter_Kling}
    'BinkleyTerm/ST',                {0104, Atari_ST, Mailer, Bill_Scull}
    'Terminate',                     {0105, Msdos/Os2/Windows, Mailer/Packer, SerWiz_Comm_&_Bo_Bendtsen}
    'TeleMail',                      {0106, Msdos, Mailer/Packer, Juergen_Weigelt}
    'CMBBS',                         {0107, Msdos/Os2, Mailer/Packer, Christof_Engel}
    'Shuttle',                       {0108, Windows, Mailer/PAcker, MCH_Development_&_Marvin_Hart}
    'Quater',                        {0109, Amiga, Mailer, Felice_Murolo}
    'Windo'                          {010A, Windows, Mailer, Alan_Chavis}
  );


const
  kwTCP                   = $17844453;
  kwVMP                   = $8A83BDB3;
  kwTEL                   = $55DFBF9A;
  kwTELNET                = $4C81E181;
  kwIFC                   = $FAB3C1EB;
  kwBINKP                 = $D83DB481;
  kwBINKD                 = $C2E760FC;
  kwBND                   = $A05B31A1;
  kwBNP                   = $BA81E5DC;
  kwIBN                   = $E06E7852;
  kwITN                   = $FCF6CD85;
  kwIVM                   = $57C9FEBD;
  kwIP                    = $49EA573B;
  kwU                     = $BC3C793A;

function IdentEMSISeq(var AStr: string): TEMSISeq;
function CompareAddrs(const a, b: TFidoAddress): Integer;
function FidoAddress(Zone, Net, Node, Point: Integer): TFidoAddress;
function BuildEMSICapabilities(Cap: TEMSICapabilities): string;
function BuildEMSILinkCodes(Cap: TEMSILinkCodes): string;
function ParseEMSILinkCodes(var S: string): TEMSILinkCodes;
function IdentEMSILinkCode(const S: string): TEMSILinkCode;
function ParseEMSICapabilities(var S: string): TEMSICapabilities;
function IdentEMSICapability(const S: string): TEMSICapability;
function IdentEMSIAddon(const S: string): TEMSIAddonType;
function CreateAddrColl(const A: string): TFidoAddrColl;
function CreateAddrCollInvAddrs(const A: string; InvAddrs: TStringColl): TFidoAddrColl;
function CreateAddrCollMsg(const A: string; var Msg: string): TFidoAddrColl;
//function CreateAddrCollMsgEx(A: string; var Msg: string; ASkip: Boolean): TFidoAddrColl;
function CreateAddrCollEx(const A: string; ASkip: Boolean): TFidoAddrColl;
function ParseEMSILine(S: String; L: TStringColl; AC: Char): Boolean;
function ExtractEMSI(var InB: string): string;
function Hex2EMSI(var S: string): Boolean;
function GetSpeed(const S: String): DWORD;
function ParseAddress(const Address: String; var Addr: TFidoAddress): Boolean;
function A4s2Addr(const a: Ta4s; var Addr: TFidoAddress): Boolean;
function ParseAddressMsg(const Address: String; var Addr: TFidoAddress; var Msg: string): Boolean;
function ValidAddress(const Address: String): Boolean;
function Addr2Str(const Addr: TFidoAddress): string;
function SplitAddress(const Address: string; var Strs: Ta4s; AllowMask: Boolean): Boolean;
function SplitAddressEx(const Address: string; var Strs: Ta4s; AllowMask, AllowREmask: Boolean): Boolean;
function PureAddressMasks(const a: Ta4s): Boolean;
function MatchMaskAddress(const Addr: TFidoAddress; const AMask: string): Boolean;
function ValidMaskAddress(const AMask: string): Boolean;
function MatchMaskAddressListMultiple(Addrs: TFidoAddrColl; const AMaskList: string): Boolean;
function MatchMaskAddressListSingle(const Addr: TFidoAddress; const AMaskList: string): Boolean;
function ValidMaskAddressList(const AMaskList: string; AHandle: DWORD): Boolean;
procedure _PutAddress(Stream: TxStream; const Addr: TFidoAddress);
procedure _GetAddress(Stream: TxStream; var Addr: TFidoAddress);
function CurFSC62Quant: TFSC62Quant;
//function NodeFSC62Time(const Flags: string; const Addr: TFidoAddress): TFSC62Time;
function NodeFSC62Local(const Flags: string): TFSC62Time;
function NodeFSC62TimeEx(Flags: string; const Addr: TFidoAddress; ALocal: Boolean): TFSC62Time;
procedure AdjustFSC62Quant(var t: TFSC62Quant; Bias: Integer);
function FSC62TimeToStr(t: TFSC62Time): string;
function IsTxy(const S: string; var Local: Boolean): Boolean;
function IdentOvrItem(const Item: string; AddrMask: Boolean; ChkFlags: Boolean): TOvrItemTyp;
function ValidOverride(const AStr: string; Dialup: Boolean; var Item: string): string;
function ParseOverride(const AAStr: string; var Msg, Item: string; Dialup: Boolean): TColl;
function WipePhoneNumber(const Phone: string): string;
function GetTransportType(Phone, Flags: string): TTransportType;
function TransportFlagsMatch(const s, z: string; Dialup: Boolean): Boolean;
function TransportMatch(const Num: string; Dialup: Boolean): Boolean;
function AreFlagsTCP(s: string): Boolean;
function ParseCronRec(s: string; Permanent, UTC: Boolean; var ErrStr: string): TCronRecord;
function ValidCronRecDlg(const s: string; Handle: DWORD; Permanent: Boolean): Boolean;
function ValidCronRecStr(const s: string): string;
function ValidCronRec(const s: string): Boolean;
function ValidCronColl(c: TStringColl; var ErrLn: Integer; var Msg: string): Boolean;
function ParseCronColl(c: TStringColl): TColl;
function ValidateAddrs(const s: string; Handle: DWORD): Boolean;
function ValidModemCmd(Idx: Integer; const Cmd, Name: string; Handle: DWORD): Boolean;
function GetNodeType(N: TFidoNode): TNodeType;
function IsArcMailExt(const AExt: string): Boolean;
procedure PurgeTimeFlags(SC: TStringColl);
procedure PurgeIpFlags(SC: TStringColl);
function HumanTime2UTxyL(ATime: string; NeedU: Boolean): string;
function OvrColl2Str(C: TColl): string;
function NewFidoAddr(const A: TFidoAddress): PFidoAddress;
function NextPollOptionMatches(var s: string; AValue: DWORD): Boolean;
function NextPollOptionValid(var s: string; Handle: DWORD): Boolean;
function PollSleepMSecsValid(var s: string; Handle: DWORD): Boolean;
function PollSleepMSecs(var s: string): DWORD;
function PollTimeoutExitCodeValid(var s: string; AHandle: DWORD): Boolean;
function PollTimeoutExitCode(var s: string): DWORD;
function GetPktFileType(const FName: string): TPktFileType;
function GetOutAttTypeByKillAction(KA: TKillAction): TOutAttType;
function OutStatus2Char(s: TOutStatus): Char;
function OutStatus2StrTmail(s: TOutStatus): string;
function Char2OutStatus(c: Char): TOutStatus;
function ValidPhnPrefix(const s: string): Boolean;

implementation uses SysUtils, xIP, LngTools, RegExp;

type
  TCronRecUnp = record
    Minutes : array[0..59] of byte;
    Hours   : array[0..23] of byte;
    Days    : array[0..30] of byte;
    Months  : array[0..11] of byte;
    Dows    : array[0..06] of Byte;
    NumMinutes, NumHours, NumDays, NumMonths, NumDows: Byte;
  end;


function Char2OutStatus(c: Char): TOutStatus;
var
  o: TOutStatus;
begin
  case UpCase(C) of
    'C': o := os_Crash;
    'D': o := os_Direct;
    'H': o := osHold;
    'N': o := osNormal;
    '*': o := osNone;
    else o := osError;
  end;
  Result := o;
end;

function OutStatus2Char(s: TOutStatus): Char;
var
  c: Char;
begin
  case s of
    os_Crash:  c := 'C';
    os_Direct: c := 'D';
    osHold:    c := 'H';
    osNone:    c := '*';
    else       c := 'N';
  end;
  Result := c;
end;

function OutStatus2StrTmail(s: TOutStatus): string;
var
  c: Char;
begin
  c := OutStatus2Char(s);
  if c = 'N' then Result := '' else Result := c;
end;

function GetOutAttTypeByKillAction(KA: TKillAction): TOutAttType;
begin
  case KA of
    kaBsoNothingAfter,
    kaBsoKillAfter,
    kaBsoTruncateAfter:
      Result := oatBSO;
    kaFbKillAfter,
    kaFbMoveAfter:
      Result := oatFileBox;
    else
      Result := oatUnk;
  end;
end;


function ValidateAddrs(const s: string; Handle: DWORD): Boolean;
var
  a: TFidoAddrColl;
  Msg: string;
begin
  a := CreateAddrCollMsg(s, Msg);
  Result := a <> nil;
  if Result then FreeObject(a) else DisplayError(Msg, Handle);
end;


function IdentEMSISeq(var AStr: string): TEMSISeq;
var
  L, I, J, K, DataLen, crc: DWORD;
  Seq: TEMSISeq;
  S3: string[3];
begin
  Result := es_None;
  I := Pos('**EMSI_', UpperCase(AStr));
  J := Pos(EMSI_TZP, AStr);
  K := Pos(EMSI_PZT, AStr);
  if I = 0 then I := High(DWORD);
  if J = 0 then J := High(DWORD);
  if K = 0 then K := High(DWORD);
  if (I > J) or (I > K) then
  begin
    if (J < K) and (J <> High(DWORD)) then
    begin
      Result := es_TZP;
      L := Length(EMSI_TZP);
      Delete(AStr, 1, J + L - 1);
    end else
    if (K <> High(DWORD)) then
    begin
      Result := es_PZT;
      L := Length(EMSI_PZT);
      Delete(AStr, 1, K + L -1);
    end;
    Exit;
  end;
  if I = High(DWORD) then Exit;
  if I > 0 then Delete(AStr, 1, I-1);
  S3 := UpperCase(Copy(AStr, 8, 3));
  for Seq := Low(Seq) to High(Seq) do with EMSI_Seq[Seq] do
  begin
    if error in O then Continue;
    if S3 <> S then Continue;
    if Length(AStr)<14 then Exit;
    if varlen in O then
    begin
      DataLen := VlH(Copy(AStr, 11, 4));
      if DataLen = INVALID_VALUE then
      begin
        Delete(AStr, 1, 14);
        Exit;
      end;
      L := Length(AStr);
      if L < 14 + DataLen + 4 then Exit else
      begin
        crc := VlH(Copy(AStr, 15+DataLen, 4));
        if (crc = INVALID_VALUE) or (crc <> Crc16UsdBlock(AStr[3], 12+DataLen)) then
        begin
          Delete(AStr, 1, 14+DataLen+4);
          if Seq = es_DAT then Result := es_DATError;
        end else
        begin
          Delete(AStr, 1, 10);  // leave Len & Data
          Result := Seq;
        end;
      end;
    end else
    begin
      crc := VlH(Copy(AStr, 11, 4));
      if (crc <> INVALID_VALUE) and (crc = Crc16UsdBlock(AStr[3], 8)) then Result := Seq;
      Delete(AStr, 1, 14);
    end;
    Exit;
  end;
  // Unknown sequence (**EMSI_????)
  if Length(AStr)>=14 then Delete(AStr, 1, 14);
end;

function Addr2Str(const Addr: TFidoAddress): string;
begin
  with Addr do if Point = 0 then
    Result := Format('%d:%d/%d', [Zone, Net, Node]) else
    Result := Format('%d:%d/%d.%d', [Zone, Net, Node, Point]);
end;

function GetSpeed(const S: String): DWORD;
var
  L,I,J: DWORD;
begin
  I := 1;
  L := Length(S);
  while (I <= L) and ((S[I] < '0') or (S[I] > '9')) do Inc(I);
  J := 0;
  while (I+J <= L) and (S[I+J] >= '0') and (S[I+J] <= '9') do Inc(J);
  if J > 0 then
  begin
    Result := Vl(Copy(S, I, J));
    if Result = INVALID_VALUE then Result := 300
  end else
  begin
    Result := 300;
  end;
end;


function BuildEMSICapabilities(Cap: TEMSICapabilities): string;
var
  C: TEMSICapability;
begin
  Result := '';
  for C := Low(TEMSICapability) to High(TEMSICapability) do
  begin
    if (C in CAP) then
    begin
      if Result <> '' then AddStr(Result, ',');
      Result := Result + SEMSICapabilities[C];
    end;
  end;
end;

function IdentEMSICapability(const S: string): TEMSICapability;
var
  C: TEMSICapability;
  US: string;
begin
  Result := ecNone;
  US := UpperCase(S);
  for C := Low(TEMSICapability) to High(TEMSICapability) do
  begin
    if US = SEMSICapabilities[C] then begin Result := C; Exit end;
  end;
end;

function ParseEMSICapabilities(var S: string): TEMSICapabilities;
var
  UnkFlags,w: string;
  C: TEMSICapability;
begin
  Result := [];
  UnkFlags := '';
  repeat
    GetWrd(s,w,',');
    if (w = '') and (s = '') then Break;
    C := IdentEMSICapability(w);
    if C = ecNone then
    begin
      if UnkFlags <> '' then AddStr(UnkFlags, ',');
      UnkFlags := UnkFlags + w;
    end else Include(Result, C);
  until False;
  S := UnkFlags;
end;

function BuildEMSILinkCodes(Cap: TEMSILinkCodes): string;
var
  C: TEMSILinkCode;
begin
  Result := '';
  for C := Low(TEMSILinkCode) to High(TEMSILinkCode) do
  begin
    if (C in CAP) then
    begin
      if Result <> '' then AddStr(Result, ',');
      Result := Result + SEMSILinkCodes[C];
    end;
  end;
end;

function IdentEMSILinkCode(const S: string): TEMSILinkCode;
var
  C: TEMSILinkCode;
  US: string;
begin
  Result := elNone;
  US := UpperCase(S);
  for C := Low(TEMSILinkCode) to High(TEMSILinkCode) do
  begin
    if US = SEMSILinkCodes[C] then begin Result := C; Exit end;
  end;
end;

function ParseEMSILinkCodes(var S: string): TEMSILinkCodes;
var
  UnkFlags,w: string;
  C: TEMSILinkCode;
begin
  Result := [];
  UnkFlags := '';
  repeat
    GetWrd(s,w,',');
    if (w = '') and (s = '') then Break;
    C := IdentEMSILinkCode(w);
    if C = elNone then
    begin
      if UnkFlags <> '' then AddStr(UnkFlags, ',');
      UnkFlags := UnkFlags + w;
    end else Include(Result, C);
  until False;
  S := UnkFlags;
end;


function NewFidoAddr(const A: TFidoAddress): PFidoAddress;
begin
  New(Result);
  Result^ := A;
end;

procedure TFidoAddrColl.Add(const A: TFidoAddress);
begin
  AtInsert(Count, NewFidoAddr(A));
end;

procedure TFidoAddrColl.Ins(const A: TFidoAddress);
begin
  Insert(NewFidoAddr(A));
end;

function TFidoAddrColl.Compare(Key1, Key2: Pointer): Integer;
begin
  Result := CompareAddrs(PFidoAddress(Key1)^, PFidoAddress(Key2)^);
end;

procedure TFidoAddrColl.FreeItem(Item: Pointer);
begin
  Dispose(PFidoAddress(Item));
end;

function TFidoAddrColl.KeyOf(Item: Pointer): Pointer;
begin
  Result := Item;
end;

procedure _PutAddress;
begin
  Stream.WriteInteger(Addr.Zone);
  Stream.WriteInteger(Addr.Net);
  Stream.WriteInteger(Addr.Node);
  Stream.WriteInteger(Addr.Point);
end;

procedure _GetAddress;
begin
  Addr.Zone := Stream.ReadInteger;
  Addr.Net := Stream.ReadInteger;
  Addr.Node := Stream.ReadInteger;
  Addr.Point := Stream.ReadInteger;
end;

procedure TFidoAddrColl.PutItem;
begin
  _PutAddress(Stream, PFidoAddress(Item)^);
end;


function TFidoAddrColl.GetItem;
begin
  Result := New(PFidoAddress);
  _GetAddress(Stream,PFidoAddress(Result)^);
end;

procedure TFidoAddrColl.SetAddress(Index: Integer; const Value: TFidoAddress);
begin
  PFidoAddress(At(Index))^ := Value;
end;

function TFidoAddrColl.GetAddress(Index: Integer): TFidoAddress;
begin
  Result := PFidoAddress(At(Index))^;
end;

function TFidoAddrColl.Crc32Item(Item: Pointer; Crc32: DWORD): DWORD;
var
  i: Integer;
begin
  Result := Crc32;
  for i := 0 to SizeOf(TFidoAddress)-1 do Result := UpdateCrc32(PxByteArray(Item)^[I], Result);
end;

function ParseAddressMsgEx(const Address: String; var Addr: TFidoAddress; PMsg: PString): Boolean;
begin
  Result := ParseAddress(Address, Addr);
  if (not Result) and (PMsg <> nil) then PMsg^ := FormatLng(rsXfNoValid, [Address]);
end;


function CreateAddrCollMsgEx(const AA: string; PMsg: PString; InvAddrs: TStringColl; ASkip: Boolean): TFidoAddrColl;
var
  A, w: string;
  C: TFidoAddrColl;
  Addr: TFidoAddress;
  P: PFidoAddress;
begin
  Result := nil;
  C := TFidoAddrColl.Create;
  A := AA;
  repeat
    GetWrd(A, w, ' ');
    if w = '' then Break;
    if not ParseAddressMsgEx(w, Addr, PMsg) then
    begin
      if ASkip then
      begin
        if InvAddrs <> nil then InvAddrs.Add(w);
        Continue;
      end else
      begin
        FreeObject(C);
        Exit;
      end;
    end;
    P := New(PFidoAddress);
    P^ := Addr;
    C.AtInsert(C.Count, P);
  until False;
  if C.Count>0 then Result := C else
  begin
    FreeObject(C);
    if PMsg <> nil then PMsg^ := LngStr(rsXfBlankFTN);
  end;
end;

function CreateAddrCollEx(const A: string; ASkip: Boolean): TFidoAddrColl;
begin
  Result := CreateAddrCollMsgEx(A, nil, nil, ASkip);
end;

function CreateAddrCollMsg(const A: string; var Msg: string): TFidoAddrColl;
begin
  Result := CreateAddrCollMsgEx(A, @Msg, nil, False);
end;

function CreateAddrCollInvAddrs(const A: string; InvAddrs: TStringColl): TFidoAddrColl;
begin
  Result := CreateAddrCollMsgEx(A, nil, InvAddrs, True);
end;


function CreateAddrColl(const A: string): TFidoAddrColl;
var
  Msg: string;
begin
  Result := CreateAddrCollMsg(A, Msg);
end;


function TFidoAddrColl.GetString: string;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to Count-1 do
  begin
    if Result <> '' then AddStr(Result, ' ');
    Result := Result + Addr2Str(Addresses[i]);
  end;
end;

function ParseEMSILine(S: String; L: TStringColl; AC: Char): Boolean;
var
  C: Char;
  Z: string;
begin
  Result := False;
  L.FreeAll;
  while S <> '' do
  begin
    Z := '';
    DelFC(S);
    repeat
      if S = '' then Exit;
      C := S[1];
      DelFC(S);
      if C <> AC then
      begin
        AddStr(Z, C);
      end else
      begin
        if (S<>'') and (S[1]=AC) then
        begin
          DelFC(S);
          AddStr(Z, C);
        end else
        begin
          L.Add(Z);
          Break;
        end;
      end;
    until False;
  end;
  Result := True;  
end;

function ExtractEMSI(var InB: string): string;
var
  J: DWORD;
begin
  Result := '';
  J := VlH(Copy(InB, 1, 4));
  if J = INVALID_VALUE then Exit;
  Result := Copy(InB, 5, J);
  Delete(InB, 1, J+8);
end;

function Hex2EMSI(var S: string): Boolean;
var
  Z: string;
  I, ZL, SL: Integer;
  C: Char;
begin
  Result := False;
  SL := Length(S);
  SetLength(Z, SL);
  I := 1; ZL := 0;
  C := '?';
  while I <= SL do
  begin
    case S[I] of
      #0..#31, #128..#255: Exit;
      '\':
        if I = SL then Exit else
        case S[I+1] of
          '\' :
            begin
              Inc(I, 2);
              C := '\';
            end;
          '0'..'9', 'a'..'f', 'A'..'F':
            if I+1 = SL then Exit else
            case S[I+2] of
              '0'..'9', 'a'..'f', 'A'..'F':
                begin
                  C := Char((Pos(UpCase(S[I+1]), rrHiHexChar)-1) shl 4 + 
                            (Pos(UpCase(S[I+2]), rrHiHexChar)-1));
                  if C < ' ' then C := '?';
                  Inc(I, 3);
                end;
              else Exit;
            end;
          else Exit;
        end;
      else
        begin
          C := S[I];
          Inc(I);
        end;
    end;
    Inc(ZL);
    Z[ZL] := C;
  end;
  S := Copy(Z, 1, ZL);
  Result := True;
end;

function IdentEMSIAddon(const S: string): TEMSIAddonType;
var
  C: TEMSIAddonType;
  US: string;
begin
  Result := eaCustom;
  US := UpperCase(S);
  for C := Low(TEMSIAddonType) to High(TEMSIAddonType) do
  begin
    if US = SEMSIAddons[C] then begin Result := C; Exit end;
  end;
end;

function ValidMaskAddress(const AMask: string): Boolean;
var
  a: Ta4s;
  RE: TPCRE;
  s: string;
begin
  Result := SplitAddress(AMask, a, True);
  if Result then Exit;
  if (Pos('~', AMask) <= 0) then begin Result := False; Exit end;
  s := StrQuotePartEx(AMask, '~', 'G', 'H');
  RE := GetRegExpr('^[\*0-9A-H]+\:[\*0-9A-H]+\/[\*0-9A-H]+(\.[\*0-9A-H]+)?$');
  Result := (RE.ErrPtr = 0) and (RE.Match(s) > 0) and (RE[0] <> '');
  RE.Unlock;
end;

function MatchMaskAddress(const Addr: TFidoAddress; const AMask: string): Boolean;
var
  a: Ta4s;
  HiC: Char;
  i, j, m: Integer;
  s,z,k,n: string;
  c: Char;
  RE: TPCRE;
  ok: Boolean;
begin
  HiC := #0;
  Result := (AMask = '*:*/*.*') or (AMask = '*:*/*');
  if Result then Exit;
  k := StrQuotePartEx(AMask, '~', #3, #4);
  if (Pos(#3, k) <= 0) then
  begin
    Replace(#4, '~', k);
    if not SplitAddress(k, a, True) then Exit;
    for i := 1 to 4 do
    begin
      s := IntToStr(Addr.arr[i]);
      z := a[i];
      if z[Length(z)] = '*' then
      begin
        DelLC(z);
        SetLength(s, Length(z));
      end;
      if s <> z then Exit;
    end;
  end else
  begin
    j := 0;
    if not SplitAddressEx(k, a, True, True) then Exit;
    for i := 1 to 4 do
    begin
      k := a[i];
      n := '';
      for m := 1 to Length(k) do
      begin
        c := k[m];
        case j of
          0:
            case c of
               #3: j := 3;
               #4: Exit;
              '*': n := n + '\d*';
              '?': n := n + '\d';
              '0'..'9': n := n + c;
              else Exit;
            end;
{          1:
            begin
              HiC := c;
              j := 2;
            end;}
          2:
            begin
              n := n + Char(VlH(HiC+c));
              j := 3;
            end;
          3:
            begin
              if c = #3 then j := 0 else begin HiC := c; j := 2 end;
            end;
        end;
      end;
      RE := GetRegExpr('^'+n+'$');
      ok := (RE.ErrPtr = 0) and (RE.Match(IntToStr(Addr.arr[i])) > 0) and (RE[0] <> '');
      RE.Unlock;
      if not ok then Exit;
    end;
  end;
  Result := True;
end;

function MatchMaskAddressListMultiple(Addrs: TFidoAddrColl; const AMaskList: string): Boolean;
var
  s, z: string;
  a: TFidoAddress;
  IsSimpleAddress: Boolean;
  i: Integer;
  Addr: TFidoAddress;
begin
  Result := False;
  s := AMaskList;
  while s <> '' do
  begin
    GetWrd(s, z, ' ');
    IsSimpleAddress := ParseAddress(z, a);
    for i := 0 to Addrs.Count-1 do
    begin
      Addr := Addrs[i];
      if IsSimpleAddress then Result := CompareAddrs(Addr, a) = 0 else
                              Result := MatchMaskAddress(Addr, z);
      if Result then Break;
    end;
    if Result then Break;
  end;
end;

function MatchMaskAddressListSingle(const Addr: TFidoAddress; const AMaskList: string): Boolean;
var
  c: TFidoAddrColl;
begin
  c := TFidoAddrColl.Create;
  c.Ins(Addr);
  Result := MatchMaskAddressListMultiple(c, AMaskList);
  c.Free;
end;

function ValidMaskAddressList(const AMaskList: string; AHandle: DWORD): Boolean;
var
  a: Ta4s;
  s,z: string;
begin
  Result := True;
  s := AMaskList;
  while s <> '' do
  begin
    GetWrd(s, z, ' ');
    if SplitAddress(z, a, True) then Continue;
    if AHandle <> INVALID_HANDLE_VALUE then DisplayError(FormatLng(rsXfNoValidAOM, [z]), AHandle);
    Result := False;
    Break;
  end;
end;


function SplitAddressEx(const Address: string; var Strs: Ta4s; AllowMask, AllowREmask: Boolean): Boolean;
var
  i,j,k: Integer;
  c: char;
  PrevMask: Boolean;
const
  wstr:string = ':/.'#0;
begin
  Result := False;
  PrevMask := False;
  j := Pos('@', Address); if j = 0 then j := Length(Address) else Dec(j);
  for i := 1 to 4 do Strs[i] := '';
  k := 1;
  for i := 1 to j do
  begin
    c := Address[i];
    case c of
      '0'..'9':
        if PrevMask then Exit else AddStr(Strs[k], c);
      'A'..'F', #3, #4: if not AllowREmask then Exit else
        begin
          if PrevMask then Exit else AddStr(Strs[k], c);
        end;
      '*':
        if (PrevMask) or (not AllowMask) then Exit else
        begin
          AddStr(Strs[k], '*');
          PrevMask := True;
        end;
      else
        if c <> wstr[k] then Exit else
        begin
          PrevMask := False;
          if Strs[k] = '' then Exit;
          Inc(k);
        end;
    end;
  end;
  case k of
    3 : begin
          Result := Strs[3] <> '';
          if Result then
          begin
            if (AllowMask and (Pos('*', Address) > 0)) or
               (AllowREMask and (Pos(#3, Address) > 0))
            then Strs[4] := '*' else Strs[4] := '0';
          end;
        end;
    4 : Result := Strs[4] <> '';
    else Result := False;
  end;
end;

function SplitAddress(const Address: string; var Strs: Ta4s; AllowMask: Boolean): Boolean;
begin
  Result := SplitAddressEx(Address, Strs, AllowMask, False);
end;

function PureAddressMasks(const a: Ta4s): Boolean;
var
  i: Integer;
  s: string;
begin
  Result := True;
  for i := 1 to 4 do
  begin
    s := a[i];
    if (Pos('*', s) > 0) and (s <> '*') then
    begin
      Result := False;
      Break;
    end;
  end;
end;

function ValidAddress(const Address: String): Boolean;
var
  A: TFidoAddress;
begin
  Result := ParseAddress(Address, A);
end;



function ParseAddressMsg(const Address: String; var Addr: TFidoAddress; var Msg: string): Boolean;
begin
  Result := ParseAddressMsgEx(Address, Addr, @Msg);
end;

function A4s2Addr(const a: Ta4s; var Addr: TFidoAddress): Boolean;
var
  e,i: DWORD;
begin
  Result := False;
  for i := 1 to 4 do
  begin
    e := Vl(a[i]);
    if (e = INVALID_VALUE) or (e > $FFFF) then Exit;
    Addr.arr[i] := e;
  end;
  Result := True;
end;

function ParseAddress;
var
  a: Ta4s;
begin
  Result := False;
  if not SplitAddress(Address, a, False) then Exit;
  Result := A4s2Addr(a, Addr);
end;

function FidoAddress;
begin
  Result.Zone := Zone;
  Result.Net := Net;
  Result.Node := Node;
  Result.Point := Point;
end;

function CompareAddrs(const a, b: TFidoAddress): Integer; assembler;
asm
   xchg eax, ecx
   mov eax, [ecx+0]
   sub eax, [edx+0]
   jnz @e
   mov eax, [ecx+4]
   sub eax, [edx+4]
   jnz @e
   mov eax, [ecx+8]
   sub eax, [edx+8]
   jnz  @e
   mov eax, [ecx+12]
   sub eax, [edx+12]
@e:
end;

constructor TFidoNode.Init;
begin
end;

function TFidoNode.Copy: TFidoNode;
begin
  Result := TFidoNode.Init;
  Result.Addr     := Addr;
  Result.Speed    := Speed;
  Result.Station  := StrAsg(Station);
  Result.Sysop    := StrAsg(Sysop);
  Result.Phone    := StrAsg(Phone);
  Result.Flags    := StrAsg(Flags);
  Result.Location := StrAsg(Location);
  Result.PrefixFlag := PrefixFlag;
end;

procedure TFidoNode.FillNodelist;
var
  i,j,k: Integer;
  s: ShortString;
  sl: byte absolute s;
  AStrL: byte absolute AStr;
  C: Char;
begin
  TreeItem := nil ;
  HasPoints := False;
  Hub     := 0;
  Speed   := 0;
  Station := '';
  Location:= '';
  Sysop   := '';
  Phone   := '';
  Flags   := '';
  PrefixFlag := APrefixFlag;
  Addr := AAddr;
  i := 1;
  j := 1;
  sl := 0;
  while i <= AStrL do
  begin
    C := AStr[i];
    if (C = '_') and (J < 4) then C := ' ';
    if (C = ',') and (J < 6) then
    begin
      case J of
        1 : Station  := S;
        2 : Location := S;
        3 : Sysop    := S;
        4 : Phone    := S;
        5 : begin
              Speed := 0;
              for k := 1 to sl do
              begin
                c := s[k];
                case c of
                  '0'..'9' : Speed := (Speed * 10) + Ord(C) - Ord('0');
                  else
                  begin
                    Speed := 0;
                    Break;
                  end;
                end;
              end;
            end;
      end;
      Inc(J);
      sl := 0;
    end else
    begin
      Inc(sl); s[sl] := C;
    end;
    Inc(i);
  end;
  Flags := s;
end;

procedure TFidoNode.FillStream(AZone, ANet: Integer; S: TxStream);
begin
  Addr.Zone := AZone;
  Addr.Net := ANet;
  Hub := S.ReadInteger;
  Addr.Node := S.ReadInteger;
  Addr.Point := S.ReadInteger;
  Byte(PrefixFlag) := S.ReadByte;
  Station :=  S.ReadStr;
  Sysop    :=  S.ReadStr;
  Speed := S.ReadInteger;
  Phone   :=  S.ReadStr;
  Flags   :=  S.ReadStr;
  Location :=  S.ReadStr;
end;

procedure TFidoNode._Store;
begin
   S.WriteInteger(Hub);
   S.WriteInteger(Addr.Node);
   S.WriteInteger(Addr.Point);
   S.WriteByte(Byte(PrefixFlag));
   S.WriteStr(Station);
   S.WriteStr(Sysop);
   S.WriteInteger(Speed);
   S.WriteStr(Phone);
   S.WriteStr(Flags);
   S.WriteStr(Location);
end;

destructor  TFidoNode.Destroy;
begin
  inherited Destroy;
end;

function TFidoNodeColl.Compare(Key1, Key2: Pointer): Integer;
begin
  Result := CompareAddrs(TFidoAddress(Key1^), TFidoAddress(Key2^));
end;

function TFidoNodeColl.KeyOf(Item: Pointer): Pointer;
begin
  Result := @TFidoNode(Item).Addr;
end;


{function IdentAnsweringOpt(const S: string): TAnsweringOption;
var
  C: TAnsweringOption;
  US: string;
begin
  Result := aoNone;
  US := UpperCase(S);
  for C := Low(TAnsweringOption) to High(TAnsweringOption) do
  begin
    if Pos(SAnsweringOptions[C], US)>0 then
    begin
      Result := C;
      Exit;
    end;
  end;
end;}

destructor TAdvNode.Destroy;
begin
  FreeObject(Ext);
  FreeObject(DialupData);
  FreeObject(IPData);
  inherited Destroy;
end;

function TAdvNode.Copy: Pointer;
var
  r: TAdvNode;
begin
  r := TAdvNode.Create;
  r.Speed := Speed;
  r.Station := StrAsg(Station);
  r.Sysop := StrAsg(Sysop);
  r.Location := StrAsg(Location);
  r.PrefixFlag := PrefixFlag;
  r.Addr := Addr;
  if DialupData <> nil then r.DialupData := DialupData.Copy;
  if IPData <> nil then r.IPData := IPData.Copy;
  if Ext <> nil then r.Ext := Ext.Copy;
  Result := r;
end;

function TAdvNodeExtData.Copy: Pointer;
var
  r: TAdvNodeExtData;
begin
  r := TAdvNodeExtData.Create;
  r.Opts := StrAsg(Opts);
  r.Cmd := StrAsg(Cmd);
  Result := r;
end;



function CurFSC62Quant: TFSC62Quant;
begin
  Result := TFSC62Quant((uGetSystemTime mod SecsPerDay) div (60*30));
end;

function IsTxy(const S: string; var Local: Boolean): Boolean;
begin
  Result := False;
  case Length(S) of
    3: Local := False;
    4: begin Local := True; if UpCase(S[4]) <> 'L' then Exit end;
    else Exit;
  end;
  if UpCase(S[1]) <> 'T' then Exit;
  Result := (S[2] in ['A'..'X', 'a'..'x']) and (S[3] in ['A'..'X', 'a'..'x']);
end;

procedure AdjustFSC62Quant(var t: TFSC62Quant; Bias: Integer);
var
  i: Integer;
begin
  i := Integer(t) + Bias div (60*30);
  if i < 0 then i := 48 + i else
  if i > 47 then i := i - 48;
  t := TFSC62Quant(i);
end;

procedure FillFSC62Time(var t: TFSC62Time; t1, t2: TFSC62Quant);
var
  i: TFSC62Quant;
begin
  if t1 <= t2 then
  begin
    Include(t, t1);
    if (t1 < High(TFSC62Quant)) and (t2 > Low(TFSC62Quant)) then for i := Succ(t1) to Pred(t2) do Include(t, i);
  end else
  begin
    for i := t1 to High(TFSC62Quant) do Include(t, i);
    if t2 > Low(TFSC62Quant) then for i := Low(TFSC62Quant) to Pred(t2) do Include(t, i);
  end;
end;

{function NodeFSC62Time(const Flags: string; const Addr: TFidoAddress): TFSC62Time;
begin
  Result := NodeFSC62TimeEx(Flags, Addr, False);
end;}

function NodeFSC62Local(const Flags: string): TFSC62Time;
begin
  Result := NodeFSC62TimeEx(Flags, FidoAddress(-1, -1, -1, -1), True);
end;

function NodeFSC62TimeEx(Flags: string; const Addr: TFidoAddress; ALocal: Boolean): TFSC62Time;
var
  z: string;
  t1, t2: TFSC62Quant;

function GetTime(C: Char; var Q: TFSC62Quant): Boolean;
var
  i: Integer;
begin
  Result := False;
  case C of
    'a'..'x', 'A'..'X' :;
    else Exit;
  end;
  i := Ord(C)-Ord('A');
  if i < 24 then Inc(i, i) else
  begin
    Dec(i, Ord('a')-Ord('A'));
    Inc(i, i+1);
  end;
  Q := TFSC62Quant(I);
  Result := True;
end;

const
  zmh: array[1..6] of TFSC62Quant = (
    09*2+0, // Zone 1 mail hour (09:00 - 10:00 UTC)
    02*2+1, // Zone 2 mail hour (02:30 - 03:30 UTC)
    17*2+0, // Zone 3 mail hour (17:00 - 18:00 UTC)
    08*2+0, // Zone 4 mail hour (08:00 - 09:00 UTC)
    01*2+0, // Zone 5 mail hour (01:00 - 02:00 UTC)
    20*2+0  // Zone 6 mail hour (20:00 - 21:00 UTC)
  );
var
  Local, u: Boolean;
begin
  u := False;
  Result := [];
  while Flags <> '' do
  begin
    GetWrd(Flags, z, ',');
    u := u or (UpperCase(z) = 'U');
    if (UpperCase(z) = 'CM') then
    begin
      Result := [Low(TFSC62Quant)..High(TFSC62Quant)];
      Exit;
    end;
    if u and IsTxy(z, Local) then
    begin
      if (GetTime(z[2], t1)) and
         (GetTime(z[3], t2)) then
      begin
        if Local <> ALocal then
        if Local then
        begin
          GetBias;
          AdjustFSC62Quant(t1, TimeZoneBias);
          AdjustFSC62Quant(t2, TimeZoneBias);
        end else
        if ALocal then
        begin
          GetBias;
          AdjustFSC62Quant(t1, -TimeZoneBias);
          AdjustFSC62Quant(t2, -TimeZoneBias);
        end;
        FillFSC62Time(Result, t1, t2);
      end;
    end;
  end;
  if {(not ALocal) and} (Addr.Point = 0) and (Result = []) then
  case Addr.Zone of
    1..6 : begin
             t1 := zmh[Addr.Zone];
             t2 := Succ(t1);
             if ALocal then
             begin
               GetBias;
               AdjustFSC62Quant(t1, -TimeZoneBias);
               AdjustFSC62Quant(t2, -TimeZoneBias);
             end;
             Include(Result, t1);
             Include(Result, t2)
           end;
  end;
end;

{ ---------------------------------------------------------------------- }

function _IdentOvrItem(const Item: string; AddrMask: Boolean; ChkFlags, InverseFlags: Boolean): TOvrItemTyp;
var
  CS: TCharSet;
  US: string;
begin
  Result := oiUnknown;
  if Item = '' then Exit;
  US := UpperCase(Item);
  FillCharSet(US, CS);
  if ValidSymAddr(Item) then
    Result := oiIPSym else
  if ValidInetAddr(Item) then Result := oiIPNum else
  if (':' in CS) or
     ('/' in CS) or
     ('.' in CS) then
  begin
    if AddrMask then
    begin
      if ValidMaskAddress(Item) then
      begin
        if ValidAddress(Item) then Result := oiAddress
                              else Result := oiAddressMask;
      end;
    end else
    begin
      if ValidAddress(Item) then Result := oiAddress;
    end;
  end else
  if '-' in CS then
  begin
    if (['+', '-', '0'..'9'] * CS = CS) and
       (Pos('--', Item) = 0) and
       (Pos('+', CopyLeft(Item, 2)) = 0) and
       (['0'..'9'] * CS <> [])
    then Result := oiPhoneNum;
  end else
  if ChkFlags then
  case US[1] of
    '!':
      if not InverseFlags then Result := _IdentOvrItem(CopyLeft(Item, 2), AddrMask, ChkFlags, True);
    'A'..'Z':
      if ['0'..'9', 'A'..'Z'] * CS = CS then
      begin
        if InverseFlags then Result := oiInvFlag else Result := oiFlag;
      end;
  end;
end;

function IdentOvrItem(const Item: string; AddrMask: Boolean; ChkFlags: Boolean): TOvrItemTyp;
begin
  Result := _IdentOvrItem(Item, AddrMask, ChkFlags, False);
end;



function ValidOverride(const AStr: string; Dialup: Boolean; var Item: string): string;
var
  L: TColl;
begin
  L := ParseOverride(AStr, Result, Item, Dialup);
  FreeObject(L);
end;

function ConflictsFSC0072(s: string): string;
var
  Local, u: Boolean;
  z, us: string;
begin
  Result := '';
  u := False;
  while s <> '' do
  begin
    GetWrd(s, z, ',');
    us := UpperCase(z);
    u := u or (us = 'U');
    if IsTxy(z, Local) then
    begin
      if not u then
      begin
        if (us <> 'TCP') and (us <> 'TEL') then
          Result := FormatLng(rsXfFSC72U, [z]);
      end;
    end;
  end;
end;

function ParseOverride(const AAStr: string; var Msg, Item: string; Dialup: Boolean): TColl;
var
  L: TColl;
  AStr: string;

function Parse: Boolean;
var
  w: string;

function ParseOvr: Boolean;
type
  TOvrTyp = (otNone, otPhoneDirect, otPhoneNodelist);
var
  s, z: string;
  nTyp: TOvrTyp;
  nPhoneDirect: string;
  nFlags: string;
  nPhoneNodelist: TFidoAddress;
  o: TOvrData;
  ioi: TOvrItemTyp;
const
  FlagOnly : array[Boolean] of integer = (rsXfFO0, rsXfFO1);
  _APD: array[Boolean] of integer = (rsXfAPD0, rsXfAPD1);
  _APN: array[Boolean] of integer = (rsXfAPN0, rsXfAPN1);
begin
  Msg := '';
  Result := False;
  nTyp := otNone;
  nPhoneDirect := '';
  nFlags := '';
  FillChar(nPhoneNodelist, SizeOf(nPhoneNodelist), 0);
  while w <> '' do
  begin
    GetWrd(w, z, ',');
    ioi := IdentOvrItem(z, False, True);
    s := '';
    case ioi of
      oiPhoneNum : if not Dialup then s := LngStr(rsXfPNNA);
      oiIPSym    : if Dialup then s := LngStr(rsXfIPSNA);
      oiIPNum    : if Dialup then
                   begin
                     if not DigitsOnly(z) then s := LngStr(rsXfIPNNA) else
                       s := FormatLng(rsXfIPNEG, ['%s', DivideDash(z)]);
                   end;
    end;
    if s <> '' then
    begin
      Msg := Format(s, [z]);
      Exit;
    end;
    case ioi of
  {-} oiAddress:
        case nTyp of
          otNone:
            begin
              if not ParseAddressMsg(z, nPhoneNodelist, Msg) then Exit;
              nTyp := otPhoneNodelist;
            end;
          otPhoneDirect:
            begin
              Msg := FormatLng(_APD[Dialup], [z, nPhoneDirect]);
              Exit;
            end;
          otPhoneNodelist:
            begin
              Msg := FormatLng(_APN[Dialup], [z, Addr2Str(nPhoneNodelist)]);
              Exit;
            end;
        end;
  {-} oiPhoneNum, oiIPSym, oiIPNum:
        case nTyp of
          otNone:
            begin
              nPhoneDirect := z;
              nTyp := otPhoneDirect;
            end;
          otPhoneDirect:
            begin
              case ioi of
                oiPhoneNum : s := LngStr(rsXfAPpdPn);
                oiIPSym    : s := LngStr(rsXfAPpdIs);
                oiIPNum    : s := LngStr(rsXfAPpdIn);
                else GlobalFail('ParseOverride("%s",...) unknown ioi on otPhoneDirect', [AAStr]);
              end;
              Msg := Format(s, [z, nPhoneDirect]);
              Exit;
            end;
          otPhoneNodelist:
            begin
              case ioi of
                oiPhoneNum : s := LngStr(rsXfAPpnPn);
                oiIPSym    : s := LngStr(rsXfAPpnIs);
                oiIPNum    : s := LngStr(rsXfAPpnIn);
                else GlobalFail('ParseOverride("%s",...) unknown ioi on otPhoneNodelist', [AAStr]);
              end;
              Msg := Format(s, [z, Addr2Str(nPhoneNodelist)]);
              Exit;
            end;
        end;
      oiFlag, oiInvFlag:
        if nTyp = otNone then
        begin
          Msg := FormatLng(FlagOnly[Dialup], [z]);
          Exit;
        end else
        begin
          if nFlags <> '' then AddStr(nFlags, ',');
          nFlags := nFlags + z;
        end;
      oiUnknown:
        begin
          Msg := FormatLng(rsXfUnrecItem, [z]);
          Exit;
        end;
    end;
  end;
  if nTyp = otNone then Exit;
  Msg := ConflictsFSC0072(nFlags);
  if Msg <> '' then Exit;
  Result := True;
  o := TOvrData.Create;
  o.PhoneDirect := StrAsg(nPhoneDirect);
  o.Flags := StrAsg(nFlags);
  o.PhoneNodelist := nPhoneNodelist;
  L.Insert(o);
end;

function ChkTransport: Boolean;
var
  i: Integer;
  o: TOvrData;

const
  TCPFlags = 'BINKD, BINKP, BND, BNP, IBN, IFC, IP, ITN, IVM, TCP, TEL, TELNET, VMP';
  CMsg: array[Boolean] of Integer = (rsXfCmsg0, rsXfCmsg1);

begin
  Result := True;
  for i := 0 to L.Count-1 do
  begin
    o := L[i];
    if o.PhoneDirect = '' then Continue;
    if not TransportFlagsMatch(o.PhoneDirect, o.Flags, Dialup) then
    begin
      Item := o.PhoneDirect;
      if o.Flags <> '' then Item := Item + ','+o.Flags;
      Msg := FormatLng(CMsg[Dialup], [TCPFlags]);
      Result := False;
      Exit;
    end;
  end;
end;


begin
  AStr := AAStr;
  Result := False;
  while AStr <> '' do
  begin
    GetWrd(AStr, w, ' ');
    Item := w;
    if not ParseOvr then Exit;
  end;
  Result := ChkTransport;
end;

begin
  L := TColl.Create;
  if not Parse then FreeObject(L);
  Result := L;
end;

function IsIpFlag(ACRC: DWORD): Boolean;
begin
  case ACRC of
    kwTCP    ,
    kwVMP    ,
    kwTEL    ,
    kwTELNET ,
    kwIFC    ,
    kwBINKP  ,
    kwBINKD  ,
    kwBND    ,
    kwBNP    ,
    kwIBN    ,
    kwITN    ,
    kwIVM    ,
    kwIP     : Result := True;
    else Result := False;
  end;
end;

procedure PurgeIpFlags;
var
  Again: Boolean;
  Idx, i: Integer;
  c: DWORD;
begin
  Again := True;
  Idx := 0;
  while Again do
  begin
    Again := False;
    for i := Idx to CollMax(SC) do
    begin
      Idx := i;
      c := CRC32Str(UpperCase(SC[i]), CRC32_INIT);
      if c = kwU then Break;
      if IsIpFlag(c) then
      begin
        SC.AtFree(i);
        Again := True;
        Break;
      end;
    end;
  end;
end;



function AreFlagsTCP(s: string): Boolean;
var
  f: TStringColl;
  i: Integer;
begin
  Result := False;
  s := UpperCase(s);
  i := Pos('U,', s);
  if i>0 then s := Copy(s, 1, i);
  f := TStringColl.Create;
  f.FillEnum(s, ',', True);
  for i := 0 to f.Count-1 do
  begin
    if IsIpFlag(CRC32Str(f[i], CRC32_INIT)) then begin Result := True; Break end;
  end;
//  Result := f.Found('TCP') or f.Found('VMP') or f.Found('TEL') or f.Found('TELNET') or f.Found('IFC') or f.Found('BINKP') or f.Found('BINKD') or f.Found('BND');
  FreeObject(f);
end;

function GetTransportType(Phone, Flags: string): TTransportType;
var
  o: TOvrItemTyp;
begin
  o := IdentOvrItem(Phone, False, False);
  Result := ttInvalid;
  if AreFlagsTCP(Flags) then
  begin
    if (o = oiIPNum) or (o = oiIPSym) then Result := ttIP;
    Exit;
  end;
  if o = oiPhoneNum then Result := ttDialup;
end;

function WipePhoneNumber(const Phone: string): string;
begin
  Result := WipeChars(Phone, '+-');
end;

function TransportMatch(const Num: string; Dialup: Boolean): Boolean;
var
  oi: TOvrItemTyp;
begin
  oi := IdentOvrItem(Num, False, False);
  Result := not (((Dialup=True) and (oi <> oiPhoneNum)) or ((Dialup=False) and (oi <> oiIPSym) and (oi <> oiIPNum)))
end;

function TransportFlagsMatch(const s, z: string; Dialup: Boolean): Boolean;
var
  tt: TTransportType;
begin
  tt := GetTransportType(s, z);
  Result := not (((Dialup=True) and (tt <> ttDialup)) or ((Dialup=False) and (tt <> ttIP)));
end;

function VlMsg(const s: string; var Rslt: DWORD; var Msg: string): Boolean;
var
  a: DWORD;
begin
  Result := False;
  a := Vl(s);
  if a = INVALID_VALUE then
  begin
    Msg := FormatLng(rsXfCrnINV, [s]);
    Exit;
  end;
  Result := True;
  Rslt := a;
end;

function VlMsgR(const s: string; Mn, Mx: DWORD; var Rslt: DWORD; var Msg: string): Boolean;
begin
  Result := VlMsg(s, Rslt, Msg);
  if not Result then Exit;
  if (Rslt >= Mn) and (Rslt <= Mx) then Exit;
  Msg := FormatLng(rsXfCrnINR, [Rslt, Mn, Mx]);
  Result := False;
end;

function ValidCronRecDlg;
var
  r: TCronRecord;
  ErrorStr: string;
begin
  r := ParseCronRec(s, Permanent, False, ErrorStr);
  Result := r <> nil;
  if Result then FreeObject(r) else
  begin
    DisplayError(ErrorStr, Handle);
  end;
end;

function ValidCronRecStr(const s: string): string;
var
  r: TCronRecord;
  ErrorStr: string;
begin
  r := ParseCronRec(s, False, False, ErrorStr);
  if r = nil then Result := ErrorStr else begin Result := ''; FreeObject(r) end;
end;

function ValidCronRec(const s: string): Boolean;
begin
  Result := ValidCronRecStr(s) = '';
end;


function ParseCronRecUnp(s: string; var r: TCronRecUnp): string;
var
  ErrMsg: string;

procedure _Get(a: PxByteArray; var Cnt: Byte; MinValue, MaxValue, OfsValue: DWORD);

function Vl(const s: string; var b: Byte): Boolean;
var
  i: DWORD;
begin
  Result := VlMsgR(s, MinValue, MaxValue, i, ErrMsg);
  if not Result then Exit;
  b := i;
end;

var
  cc: Integer;
  skp, step: Byte;

procedure Add(b: Byte);
var
  i: Integer;
begin
  Dec(b, OfsValue);
  for i := 0 to cc-1 do
  begin
    if a^[i] = b then Exit;
  end;
  a^[cc] := b;
  Inc(cc);
end;


procedure AddSkp(b: Byte);
begin
  if skp = 0 then Add(b);
  Inc(skp);
  if skp >= step then skp := 0;
end;

procedure VE;
begin
  ErrMsg := LngStr(rsXfCrnVE);
end;

var
  z,k,l,st: string;
  b,mn,mx: Byte;
begin
  step := 0;
  GetWrd(s, z, ' ');
  if z = '' then
  begin
    if MaxValue = 59 then
    begin
      VE; Exit;
    end else
    begin
      z := '*';
    end;
  end;
  cc := 0;
  repeat
    if z <> '*' then
    begin
      if Pos ('/', z) > 0 then
      begin
        st := z;
        GetWrd(st, z, '/');
        if not Vl(st, step) then Exit;
        if z = '*' then
        begin
          b := MinValue;
          repeat
            Add(b);
            Inc(b, step);
          until b > MaxValue;
          Break;
        end;
      end;
      while z <> '' do
      begin
        GetWrd(z, k, ',');
        if Pos('-', k) = 0 then
        begin
          if not Vl(k, b) then Exit;
          if step = 0 then Add(b) else
          begin
            repeat
              Add(b);
              Inc(b, step);
            until b > MaxValue;
          end;
        end else
        begin
          GetWrd(k, l, '-');
          if not Vl(l, mn) then Exit;
          if not Vl(k, mx) then Exit;
          skp := 0;
          if mx >= mn then for b := mn to mx do AddSkp(b) else
          begin
            for b := mn to MaxValue do AddSkp(b);
            skp := 0;
            for b := MinValue to mx do AddSkp(b);
          end;
        end;
      end;
    end;
  until True;
  Cnt := cc;
end;

function Get(a: PxByteArray; var Cnt: Byte; MinValue, MaxValue, OfsValue: Byte): Boolean;

procedure QuickSort(L, R: Byte);
var
  T, P: Byte;
  I, J: Integer;
begin
  repeat
    I := L;
    J := R;
    P := a^[(L + R) shr 1];
    repeat
      while a^[I] < P do Inc(I);
      while a^[J] > P do Dec(J);
      if I <= J then
      begin
        T := a^[I];
        a^[I] := a^[J];
        a^[J] := T;
        Inc(I);
        Dec(J);
      end;
    until I > J;
    if L < J then QuickSort(L, J);
    L := I;
  until I >= R;
end;

begin
  Cnt := $FF;
  _Get(a, Cnt, MinValue, MaxValue, OfsValue);
  Result := Cnt <> $FF;
  if Result and (Cnt>1) then QuickSort(0, Cnt-1);
end;

function NoMore: Boolean;
begin
  Result := Trim(s) = '';
  if not Result then ErrMsg := FormatLng(rsXfCrnUS, [s]);
end;

begin
    ErrMsg := 'Cron Format Error!!!';
    with r do
    if Get(@Minutes, NumMinutes, 0, High(Minutes), 0) and
       Get(@Hours, NumHours, 0, High(Hours), 0) and
       Get(@Days, NumDays, 1, High(Days)+1, 1) and
       Get(@Months, NumMonths, 1, High(Months)+1, 1) and
       Get(@Dows, NumDows, 1, High(Dows)+1, 1) and
       NoMore then Result := '' else
       begin
         if Trim(ErrMsg) = '' then GlobalFail('ParseCronRec("%s",...) ErrMsg=<empty>', [s]);
         Result := ErrMsg;
       end;
end;

function ParseCronRec(s: string; Permanent, UTC: Boolean; var ErrStr: string): TCronRecord;
var
  pk: TCronRecUnp;
  r: TCronRec;
  i: Integer;
  z: string;
begin
  Clear(r, SizeOf(r));
  Result := TCronRecord.Create;
  Result.IsUTC := UTC;
  if Permanent then
  begin
    Result.IsPermanent := True;
    ErrStr := '';
    Exit;
  end;
  repeat
    GetWrd(s, z, ';');
    ErrStr := ParseCronRecUnp(z, pk);
    if ErrStr <> '' then begin FreeObject(Result); Exit; end;
    if pk.NumMinutes = 0 then r.Minutes := [0..High(T_Minute)] else for i := 0 to pk.NumMinutes-1 do Include(r.Minutes, pk.Minutes[i]);
    if pk.NumHours = 0 then r.Hours := [0..High(T_Hour)] else for i := 0 to pk.NumHours-1 do Include(r.Hours, pk.Hours[i]);
    if pk.NumDays = 0 then r.Days := [0..High(T_Day)] else for i := 0 to pk.NumDays-1 do Include(r.Days, pk.Days[i]);
    if pk.NumMonths = 0 then r.Months := [0..High(T_Month)] else for i := 0 to pk.NumMonths-1 do Include(r.Months, pk.Months[i]);
    if pk.NumDows = 0 then r.Dows := [0..High(T_Dow)] else for i := 0 to pk.NumDows-1 do Include(r.Dows, pk.Dows[i]);
    Inc(Result.Count);
    ReallocMem(Result.p, Result.Count * SizeOf(TCronRec));
    Result.p^[Result.Count-1] := r;
    s := Trim(s);
    if s = '' then Break;
    Clear(r, SizeOf(r));
  until False;
end;

{var
  z: string;
begin
  repeat
    GetWrd(s, z, ';);
    ParseCronRec(z, r, Permanent;
  until s = '';
end;}


function _ParseCronColl(c: TStringColl; var ErrLn: Integer; var Msg: string): TColl;
var
  i: Integer;
  s, ec: string;
  r: TCronRecord;
begin
  Result := nil;
  for i := 0 to c.Count-1 do
  begin
    s := c[i];
    r := ParseCronRec(s, False, False, ec);
    if r <> nil then
    begin
      if Result = nil then Result := TColl.Create;
      Result.Insert(r);
    end else
    begin
      ErrLn := i+1;
      Msg := ec;
      FreeObject(Result);
      Break;
    end;
  end;
end;


function ValidCronColl(c: TStringColl; var ErrLn: Integer; var Msg: string): Boolean;
var
  cc: TColl;
begin
  cc := _ParseCronColl(c, ErrLn, Msg);
  Result := cc <> nil;
  FreeObject(cc);
end;

function ParseCronColl(c: TStringColl): TColl;
var
  i: Integer;
  s: string;
begin
  Result := _ParseCronColl(c, i, s);
end;

function InvalidateModemCmdStr(const AName, AStr: string; FinalChar: Char; ValidOnLetters: Boolean): string;
var
  fc, s: string;
  CharSet: TCharSet;
  c: Char;
  err: Boolean;
begin
  Result := '';
  s := _DelSpaces(UpperCase(AStr));
  if FinalChar = #0 then fc := 'non-CR' else fc := FinalChar;
  if ValidOnLetters then
  begin
    FillCharSet(s, CharSet);
    if CharSet * ['A'..'Z'] = [] then Exit; ///
  end;
  if s = '' then Result := FormatLng(rsXfTplEmpty, [AName, fc]) else
  begin
    c := s[Length(s)];
    if FinalChar = #0 then err := (c = '!') or (c = '|') else err := c <> FinalChar;
    if err then Result := FormatLng(rsXfTplChar, [AName, AStr, c, AName, fc]);
  end;
end;



function ValidModemCmd(Idx: Integer; const Cmd, Name: string; Handle: DWORD): Boolean;
const
  FinalChars: array[0..MaxModemCmdIdx] of Char = ('|', '!', #0, '!', #1, #1);
  VOLs: array[0..MaxModemCmdIdx] of Boolean = (True, True, False, False, False, False);
var
  c: Char;
  s: string;
begin
  Result := True;
  c := FinalChars[Idx];
  if c = #1 then Exit;
  s := InvalidateModemCmdStr(Name, Cmd, c, VOLs[Idx]);
  if s = '' then Exit;
  Result := YesNoWarning(s, Handle);
end;

function GetNodeType(N: TFidoNode): TNodeType;
begin
  if N.Addr.Point <> 0 then Result := fntPoint else
  if N.Addr.Node <> 0 then
  begin
    if N.Hub = N.Addr.Node then Result := fntHub else Result := fntNode;
  end else
  if N.Addr.Net = N.Addr.Zone then Result := fntZone else
  if N.Addr.Net < 100 then Result := fntRegion else Result := fntNet;
end;

function IsArcMailExt(const AExt: string): Boolean;
var
  s: string;
begin
  s := UpperCase(Copy(AExt, 2, Length(AExt)-2));
  Result :=
  (s = 'SU') or
  (s = 'MO') or
  (s = 'TU') or
  (s = 'WE') or
  (s = 'TH') or
  (s = 'FR') or
  (s = 'SA');
end;


procedure PurgeTimeFlags(SC: TStringColl);
var
  i, Idx: Integer;
  uu, ok, Local: Boolean;
  s: string;
begin
  Idx := 0;
  uu := False;
  repeat
    ok := True;
    for i := Idx to CollMax(SC) do
    begin
      Idx := i;
      s := UpperCase(SC[i]);
      if not uu then
      begin
        if s = 'U' then
        begin
          uu := True;
          Continue;
        end;
        if s = 'CM' then
        begin
          ok := False; SC.AtFree(i); Break
        end;
        Continue;
      end;
      if IsTxy(s, Local) then
      begin
        ok := False; SC.AtFree(i); Break
      end;
    end;
  until ok;
  i := CollMax(SC);
  if (i >= 0) and (UpperCase(SC[i]) = 'U') then SC.AtFree(i);
end;

function FSC62QuantToStr(t: TFSC62Quant): string;
begin
  Result := Format('%.2d:%.2d', [Integer(t) div 2, (Integer(t) mod 2)*30]);
end;

function FSC62QuantToChar(t: TFSC62Quant): Char;
begin
  Result := Char(Ord('A') + Integer(t) div 2 + (Ord('a')-Ord('A'))*(Integer(t) mod 2));
end;

function FSC62TimeToStr(t: TFSC62Time): string;
var
  Heads, Tails: array[0..23] of TFSC62Quant;
  FirstPair, NumPairs: Integer;
  i: TFSC62Quant;
  ScanHead: Boolean;
  s: string;
begin
  if t = [Low(TFSC62Quant)..High(TFSC62Quant)] then
  begin
    Result := 'CM';
    Exit;
  end;
  FirstPair := 0;
  NumPairs := 0;
  ScanHead := True;
  for i := Low(TFSC62Quant) to High(TFSC62Quant) do
  begin
    if ScanHead then
    begin
      if (i in t) then
      begin
        Heads[NumPairs] := i;
        ScanHead := False;
      end;
    end else
    begin // Scan Tail
      if not (i in t) then
      begin
        Tails[NumPairs] := i;
        Inc(NumPairs);
        ScanHead := True;
      end;
    end;
  end;
  if not ScanHead then
  begin
    Tails[NumPairs] := Low(TFSC62Quant);
    Inc(NumPairs);
  end;
  if (NumPairs > 1) and (Tails[NumPairs-1] = Heads[0]) then
  begin
    Tails[NumPairs-1] := Tails[0];
    FirstPair := 1;
  end;
  s := '';
  if NumPairs > 0 then
  for i := FirstPair to Pred(NumPairs) do
  begin
    if s <> '' then s := s + ',';
    s := s + FSC62QuantToStr(Heads[i]) + '-' + FSC62QuantToStr(Tails[i]);
  end;
  Result := s;
end;

function H2xCvtOK(var s: string): Boolean;
var
  s1, s2: string;
  a1, a2: DWORD;
  c: Char;
begin
  Result := False;
  GetWrd(s, s1, ':');
  GetWrd(s, s2, ':');
  if s <> '' then Exit;
  a1 := Vl(s1); if a1 = INVALID_VALUE then Exit;
  if a1 = 24 then a1 := 0;
  a2 := Vl(s2); if a2 = INVALID_VALUE then Exit;
  if (a1>23) then Exit;
  if (a2>59) then Exit;
  c := Char(Ord('a')+a1);
  if a2 < 30 then c := UpCase(c);
  s := c;
  Result := True;
end;

function HumanTime2TxyToken(ATime: string): string;
var
  s1, s2: string;
begin
  Result := '';
  GetWrd(ATime, s1, '-');
  GetWrd(ATime, s2, '-');
  if ATime <> '' then Exit;
  if H2xCvtOK(s1) and H2xCvtOK(s2) then Result := Format('T%s%sL', [s1, s2]);
end;

function HumanTime2UTxyL;
var
  s: string;
  c: TStringColl;
begin
  if UpperCase(ATime) = 'CM' then begin Result := 'CM'; Exit end;
  c := TStringColl.Create;
  while ATime <> '' do
  begin
    GetWrd(ATime, s, ',');
    s := HumanTime2TxyToken(s);
    if s <> '' then c.Add(s);
  end;
  if c.Count>0 then
  begin
    if NeedU then Result := 'U,' else Result := '';
    Result := Result + c.LongStringD(',')
  end else Result := '';
  FreeObject(c);
end;


function OvrColl2Str(C: TColl): string;
var
  s, z: string;
  O: TOvrData;
  i: Integer;
begin
  z := '';
  for i := 0 to CollMax(C) do
  begin
    O := C[i];
    s := O.PhoneDirect;
    if s = '' then s := Addr2Str(O.PhoneNodelist);
    if O.Flags <> '' then s := s + ',' + O.Flags;
    if z <> '' then z := z + ' ';
    z := z + s;
  end;
  Result := z;
end;


function TAdvNodeData.Copy: Pointer;
var
  r: TAdvNodeData;
begin
  r := TAdvNodeData.Create;
  r.Flags := StrAsg(Flags);
  r.Phone := StrAsg(Phone);
  r.IPAddr := StrAsg(IPAddr);
  Result := r;
end;


function NextPollOptionMatchesMsg(var s, ErrMsg: string; AValue: DWORD): Boolean;

var
  z,k,l: string;
  b,mn,mx: DWORD;

procedure InvRange;
begin
  ErrMsg := FormatLng(rsRecsInvCRro, [mn, mx]);
end;

begin
  Result := False;
  GetWrd(s, z, ' ');
  if (z = '') or (z = '.') then Exit;
  while z <> '' do
  begin
    GetWrd(z, k, ',');
    if Pos('-', k) = 0 then
    begin
      if not VlMsg(k, b, ErrMsg) then Exit;
      if AValue = b then begin Result := True; Exit; end;
    end else
    begin
      GetWrd(k, l, '-');
      if not VlMsg(l, mn, ErrMsg) then Exit;
      if not VlMsg(k, mx, ErrMsg) then Exit;
      if mn > mx then begin InvRange; Exit end;
      if (AValue >= mn) and (AValue <= mx) then begin Result := True; Exit; end;
    end;
  end;
end;

function NextPollOptionMatches(var s: string; AValue: DWORD): Boolean;
var
  Msg: string;
begin
  Result := NextPollOptionMatchesMsg(s, Msg, AValue);
end;

function NextPollOptionValid(var s: string; Handle: DWORD): Boolean;
var
  Msg: string;
  i: DWORD;
begin
  i := INVALID_VALUE;
  NextPollOptionMatchesMsg(s, Msg, i);
  Result := Msg = '';
  if not Result then DisplayError(Msg, Handle);
end;

function NextPollSleepMSecsMsg(var s, ErrMsg: string): DWORD;
var
  z: string;
begin
  GetWrd(s, z, ' ');
  if z = '' then
  begin
    Result := INFINITE;
    Exit;
  end;
  if VlMsg(z, Result, ErrMsg) then Result := Result * 1000 * 60;
end;

function PollSleepMSecs(var s: string): DWORD;
var
  z, Msg: string;
begin
  z := s;
  Result := NextPollSleepMSecsMsg(z, Msg);
  if Msg <> '' then GlobalFail('PollSleepMSecs("%s")', [s]);
end;

function PollSleepMSecsValid(var s: string; Handle: DWORD): Boolean;
var
  Msg: string;
begin
  NextPollSleepMSecsMsg(s, Msg);
  Result := Msg = '';
  if not Result then DisplayError(Msg, Handle);
end;

function PollTimeoutExitCodeMsg(var s, Msg: string): DWORD;
var
  z: string;
begin
  GetWrd(s, z, ' ');
  if z = '' then
  begin
    Result := 1;
    Exit;
  end;
  VlMsg(z, Result, Msg);
end;

function PollTimeoutExitCodeValid(var s: string; AHandle: DWORD): Boolean;
var
  Msg: string;
begin
  PollTimeoutExitCodeMsg(s, Msg);
  Result := Msg = '';
  if not Result then DisplayError(Msg, AHandle);
end;

function PollTimeoutExitCode(var s: string): DWORD;
var
  z, Msg: string;
begin
  z := s;
  Result := PollTimeoutExitCodeMsg(z, Msg);
  if Msg <> '' then GlobalFail('PollTimeoutExitCode("%s")', [s]);
end;

function GetPktFileType(const FName: string): TPktFileType;
var
  pktP2K: TType2000HeaderV5;
  pkt0001: TFTS1PktHdr absolute pktP2K;
  pkt0039: TFSC39PktHdr absolute pkt0001;
  pkt0045: TFSC45PktHdr absolute pkt0001;
  h, Actually: DWORD;
begin
  Result := pftUnknown;
  h := _CreateFile(FName, [cRead, cSequentialScan, cShareAllowWrite]);
  if h = INVALID_HANDLE_VALUE then
  begin
    Result := pftOpenErr;
    Exit;
  end;
  ReadFile(h, pktP2K, SizeOf(pktP2K), Actually, nil);
  ZeroHandle(h);
  if Actually < 60 then
  begin
    Result := pftReadErr;
    Exit;
  end;
  if Actually = SizeOf(pktP2K) then
  begin
    // Try to determine P2K
    if (pktP2K.MainHeaderLen = 126) and
       (pktP2K.SubHeaderLen = 43) and
       (pktP2K.PktVersionMajor = 2000) then
    begin
      // This is a P2K packet
      Result := pftP2K;
      Exit;
    end;
  end;

  if pkt0001.rate = 2 then
  begin
    // This is a FSC-0045 (type 2.2) packet!
    Result := pftFSC45;
    Exit;
  end else
  begin
    if Swap(pkt0039.CapValid) = pkt0039.CapWord then
    begin
      // This is a FSC-0039 packet!
      Result := pftFSC39;
      Exit;
    end else
    begin
      // FTS-0001 or bullshitted packet.
      if (pkt0001.month  < 13) and
         (pkt0001.day    < 32) and
         (pkt0001.hour   < 25) and
         (pkt0001.minute < 61) and
         (pkt0001.second < 61) then
      begin
        Result := pftFTS1;
        Exit;
      end;
    end;
  end;
end;

destructor TCronRecord.Destroy;
begin
  if p <> nil then ReallocMem(p, 0);
  inherited Destroy;
end;

function ValidPhnPrefix(const s: string): Boolean;
var
  i: Integer;
begin
  Result := (s = '') or (s = '-');
  if Result then Exit;
  Result := True;
  for i := 1 to Length(s) do
  case s[i] of
    '0'..'9': ;
    else begin Result := False; Break end;
  end;
  if Result then Exit;
  Result := IdentOvrItem(s, False, False) = oiPhoneNum;
end;


end.


