unit MainZt;

interface

uses
  Windows, Messages, SysUtils, Graphics, Forms, IniFiles, ComObj, Grobal2,
  EDcode, JSocket, Winsock, RzLabel, IdHTTP, Md5, GameLoginShare, Dialogs,
  RzBmpBtn, RzCmboBx, RzButton, RzRadChk, ExtCtrls, StdCtrls, Classes,
  RzPrgres, Common, RzPanel, IdTCPConnection, IdTCPClient, IdComponent,
  IdBaseComponent, SHDocVw, OleCtrls, ComCtrls, Controls, IdAntiFreezeBase,
  IdAntiFreeze, WinInet, WinHTTP, jpeg, Reg, EDcodeUnit, Main;
type
  TFrmMainZt = class(TFrmMain)
    MainImage: TImage;
    WebBrowser1: TWebBrowser;
    RzPanel1: TRzPanel;
    ClientSocket: TClientSocket;
    ClientTimer: TTimer;
    TreeView1: TTreeView;
    RzLabel3: TRzLabel;
    RzLabel1: TRzLabel;
    RzLabel2: TRzLabel;
    ProgressBarAll: TRzProgressBar;
    ProgressBarCurDownload: TRzProgressBar;
    RzLabelStatus: TRzLabel;
    IdHTTP1: TIdHTTP;
    StartButton: TRzBmpButton;
    ButtonHomePage: TRzBmpButton;
    ButtonAddGame: TRzBmpButton;
    ImageButton4: TRzBmpButton;
    ButtonNewAccount: TRzBmpButton;
    ButtonChgPassword: TRzBmpButton;
    ButtonGetBackPassword: TRzBmpButton;
    ImageButtonClose: TRzBmpButton;
    MinimizeBtn: TRzBmpButton;
    CloseBtn: TRzBmpButton;
    CheckBoxHideSplashForm: TRzCheckBox;
    RzComboBoxClitntVer: TRzComboBox;
    RzLabel8: TRzLabel;
    Timer3: TTimer;
    IdAntiFreeze: TIdAntiFreeze;
    ServerSocket: TServerSocket;
    WinHTTP: TWinHTTP;
    TimerPatchSelf: TTimer;
    procedure MainImageMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MinimizeBtn1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TimeGetGameListTimer(Sender: TObject);
    procedure SendCSocket(sendstr: string);
    procedure ClientSocketConnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ClientSocketConnecting(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ClientSocketDisconnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ClientSocketError(Sender: TObject; Socket: TCustomWinSocket;
      ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure ClientSocketRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure ClientTimerTimer(Sender: TObject);
    procedure DecodeMessagePacket(datablock: string);
    procedure TreeView1Expanding(Sender: TObject; Node: TTreeNode;
      var AllowExpansion: Boolean);
    procedure TreeView1AdvancedCustomDraw(Sender: TCustomTreeView;
      const ARect: TRect; Stage: TCustomDrawStage;
      var DefaultDraw: Boolean);
    procedure FormShow(Sender: TObject);
    procedure TimerPatchTimer(Sender: TObject);
    procedure IdHTTP1Work(Sender: TObject; AWorkMode: TWorkMode;
      const AWorkCount: Integer);
    procedure IdHTTP1WorkBegin(Sender: TObject; AWorkMode: TWorkMode;
      const AWorkCountMax: Integer);
    procedure StartButtonClick(Sender: TObject);
    procedure ButtonHomePageClick(Sender: TObject);
    procedure ButtonAddGameClick(Sender: TObject);
    procedure ButtonNewAccountClick(Sender: TObject);
    procedure ButtonChgPasswordClick(Sender: TObject);
    procedure ButtonGetBackPasswordClick(Sender: TObject);
    procedure ImageButtonCloseClick(Sender: TObject);
    procedure MinimizeBtnClick(Sender: TObject);
    procedure CloseBtnClick(Sender: TObject);
    procedure SecrchTimerTimer(Sender: TObject);
    procedure TreeView1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TimerKillCheatTimer(Sender: TObject);
    procedure Timer3Timer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure WinHTTPDone(Sender: TObject; const ContentType: string;
      FileSize: Integer; Stream: TStream);
    procedure WinHTTPHTTPError(Sender: TObject; ErrorCode: Integer;
      Stream: TStream);
    procedure WinHTTPHostUnreachable(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure TimerPatchSelfTimer(Sender: TObject);
  private
    dwClickTick: LongWord;
    
    function WriteInfo(sPath: string): Boolean;
    procedure ServerActive; //20080310
    procedure ButtonActive; //按键激活   20080311
    procedure ButtonActiveF; //按键激活   20080311
    procedure AnalysisFile();
    procedure LoadPatchList(str: TStream);
    procedure LoadGameMonList(str: TStream);
    function DownLoadFile(sURL, sFName: string): boolean; //下载文件
    function LoadOptions(): Boolean;
  public
    procedure LoadServerList(str: TStream);
    procedure LoadLocalGameList(); //读取本地游戏列表
    procedure LoadServerTreeView();
    procedure LoadLocalTreeView();
    procedure LoadSelfInfo();

    procedure SendUpdateAccount(ue: TUserEntry; ua: TUserEntryAdd); override; //发送新建账号
    procedure SendChgPw(sAccount, sPasswd, sNewPasswd: string); override; //发送修改密码
    procedure SendGetBackPassword(sAccount, sQuest1, sAnswer1, sQuest2, sAnswer2, sBirthDay: string); override; //发送找回密码
    procedure CreateParams(var Params: TCreateParams); override; //设置程序的类名 20080412
  protected
    procedure SetEnabledServerList(Value: Boolean); override;
    procedure SetStatusString(const Value: string); override;
    procedure SetStatusColor(const Value: TColor); override;
  end;

var
  FrmMainZt: TFrmMainZt;
  HomeURL: string;
{$IF GVersion = 0}
  GameListURL: pchar = 'http://www.igem2.cn/QKServerList.txt';
  PatchListURL: pchar = 'http://www.igem2.cn/QKPatchList.txt';
  GameESystemURL: pchar = 'http://www.igem2.com';
{$IFEND}
  NowNode: TTreeNode = nil;

implementation
uses HUtil32, NewAccount, ChangePassword, GetBackPassword, Secrch, EditGame,
  MsgBox, GameMon, Image2, StrUtils;
{$R *.dfm}



procedure TFrmMainZt.SetEnabledServerList(Value: Boolean);
begin
  TreeView1.Enabled := Value;
end;

procedure TFrmMainZt.SetStatusString(const Value: string);
begin
  RzLabelStatus.Caption := Value;
end;

procedure TFrmMainZt.SetStatusColor(const Value: TColor);
begin
  RzLabelStatus.Font.Color := Value;
end;

procedure TFrmMainZt.WinHTTPHTTPError(Sender: TObject; ErrorCode: Integer;
  Stream: TStream);
begin
  case GetUrlStep of
    ServerList, ReServerList: begin
        TreeView1.Items.Clear;
        TreeView1.Items.Add(nil, {'获取服务器列表失败...'} SetDate('逮钱格窿渗芜锯浓坑!!!'));
        LoadLocalGameList();
      end;
    UpdateList: begin
        GetUrlStep := GameMonList;
        TimeGetGameList.Enabled := True;
      end;
    GameMonList: g_boGameMon := False;
  end;
end;
//认证Mir2.exe By TasNat at: 2012-03-10 11:39:44



function TFrmMainZt.LoadOptions(): Boolean;
{  //十进制数转换成十六进制数
  function CnIntToHex(Value: Longint; Digits: Integer): String;
  begin
    Result := IntToHex(Word(Value), Digits);
  end;}
var
  str: TMemoryStream;
  Flag1, Flag2, Flag3, Flag4, Flag5: WORD;
begin
  Result := False;
  str := TMemoryStream.Create;
  try
    MainImage.Picture.Graphic.SaveToStream(str);
    str.Position := 14848;
    str.Read(Flag1, SizeOf(Flag1));
    str.Position := 10656;
    str.Read(Flag2, SizeOf(Flag2));
    str.Position := 15104;
    str.Read(Flag3, SizeOf(Flag3));
    str.Position := 15360;
    str.Read(Flag4, SizeOf(Flag4));
    str.Position := 15552;
    str.Read(Flag5, SizeOf(Flag5));
    Result := (Flag2 = JPEG_FLAG2) and (Flag1 = JPEG_FLAG1) and (Flag3 = JPEG_FLAG3) and (Flag4 = JPEG_FLAG4) and (Flag5 = JPEG_FLAG5);
    //Memo1.Lines.Add({CnIntToHex(Flag2, 4)+'   '+}inttostr(str.Size));
  finally
    str.Free;
  end;
end;


//读出自身的信息

procedure TFrmMainZt.LoadSelfInfo();
var
  //StrList: TStringList;
  Source, str: TMemoryStream;
  RcSize: integer;
begin
{$IF Testing <> 0}
  ExtractInfo('C:\1.exe', MyRecInfo); //读出自身的信息
{$ELSE}
  ExtractInfo(Application.ExeName, MyRecInfo); //读出自身的信息
{$IFEND}
  if MyRecInfo.GameListURL <> '' then begin
    LnkName := MyRecInfo.lnkName;
{$IF GVersion = 1}
    g_GameListURL := MyRecInfo.GameListURL;
    g_PatchListURL := MyRecInfo.PatchListURL;
    g_boGameMon := True; //MyRecInfo.boGameMon;
    g_GameMonListURL := MyRecInfo.GameMonListURL;
    GameESystemURL := MyRecInfo.GameESystemUrl;
    ClientFileName := MyRecInfo.ClientFileName;
{$IFEND}
    m_sLocalGameListName := MyRecInfo.ClientFileName;

    if MyRecInfo.TzHintListFileSize > 0 then begin //套装文件大小 20110305
      Source := TMemoryStream.Create;
      str := TMemoryStream.Create;
      try //读取套装文件
        try
{$IF Testing <> 0}
          Source.LoadFromFile('C:\1.exe');
{$ELSE}
          Source.LoadFromFile(Application.ExeName);
{$IFEND}
        //LoadResToMemStream(Source);
          RcSize := MyRecInfo.SourceFileSize;
          Source.Seek(RcSize, soFromBeginning);
          str.CopyFrom(Source, MyRecInfo.TzHintListFileSize);
          DeCompressStream(str); //解压流
          str.Position := 0;
          str.SaveToFile(PChar(g_sMirPath) + Setdate(TzHintList)); //TzHintList.txt 保存套装文件
        except
          FrmMessageBox.LabelHintMsg.Caption := '请检查传奇目录是否开启了只读属性！';
          FrmMessageBox.ShowModal;
        end;
      finally
        str.Free;
        Source.Free;
      end;
    end;
    if MyRecInfo.PulsDescFileSize > 0 then begin //经络文件大小 20110305
      Source := TMemoryStream.Create;
      str := TMemoryStream.Create;
      try //读取文件
        try
{$IF  Testing =1}
          Source.LoadFromFile('C:\1.exe');
{$ELSE}
          Source.LoadFromFile(Application.ExeName);
{$IFEND}

      //LoadResToMemStream(Source);
          RcSize := MyRecInfo.SourceFileSize + MyRecInfo.TzHintListFileSize;
          Source.Seek(RcSize, soFromBeginning);
          str.CopyFrom(Source, MyRecInfo.PulsDescFileSize);
          DeCompressStream(str); //解压流
          str.Position := 0;
          str.SaveToFile(PChar(g_sMirPath) + {'Data\PulsDesc.dat'} Setdate('Kn{nS_zc|Kj|l!kn{')); //保存经络文件PulsDesc.txt
        except
          FrmMessageBox.LabelHintMsg.Caption := '请检查传奇目录是否开启了只读属性！';
          FrmMessageBox.ShowModal;
        end;
      finally
        str.Free;
        Source.Free;
      end;
    end;
    if MyRecInfo.GameSdoFilterFileSize > 0 then begin //内挂文件 20110305
      Source := TMemoryStream.Create;
      str := TMemoryStream.Create;
      try //读取文件
        try
{$IF  Testing =1}
          Source.LoadFromFile('C:\1.exe');
{$ELSE}
          Source.LoadFromFile(Application.ExeName);
{$IFEND}

        //LoadResToMemStream(Source);
          RcSize := MyRecInfo.SourceFileSize + MyRecInfo.TzHintListFileSize + MyRecInfo.PulsDescFileSize;
          Source.Seek(RcSize, soFromBeginning);
          str.CopyFrom(Source, MyRecInfo.GameSdoFilterFileSize);
          DeCompressStream(str); //解压流
          str.Position := 0;
          str.SaveToFile(PChar(g_sMirPath) + Setdate(FilterItemNameList)); //FilterItemNameList.dat
        except
          FrmMessageBox.LabelHintMsg.Caption := '请检查传奇目录是否开启了只读属性！';
          FrmMessageBox.ShowModal;
        end;
      finally
        str.Free;
        Source.Free;
      end;
    end;
    Application.Title := MyRecInfo.lnkName;
  end;
{$IF GVersion = 0}
  ClientFileName := '0.exe';
  m_sLocalGameListName := '1.txt';
{$IFEND}
end;

//把信息添假到树型列表里

procedure TFrmMainZt.LoadLocalTreeView();
var
  ServerInfo, ServerInfo1: pTServerInfo;
  TmpNode: TTreeNode;
  I, K, J: integer;
  BB: Boolean;
begin
  for I := 0 to g_LocalServerList.Count - 1 do begin
    BB := False;
    ServerInfo := pTServerInfo(g_LocalServerList.Items[I]);
    if TreeView1.Items <> nil then
      for J := 0 to TreeView1.Items.Count - 1 do begin
        if CompareText(ServerInfo.ServerArray, TreeView1.Items[j].Text) = 0 then BB := True;
      end;
    if BB then Continue;
    TmpNode := TreeView1.Items.Add(nil, ServerInfo.ServerArray);
    for K := 0 to g_LocalServerList.Count - 1 do begin
      ServerInfo1 := pTServerInfo(g_LocalServerList.Items[K]);
      if CompareText(ServerInfo.ServerArray, ServerInfo1.ServerArray) = 0 then
        TreeView1.Items.AddChildObject(TmpNode, ServerInfo1.ServerName, ServerInfo1);
    end;
  end;
end;
//把信息添假到树型列表里

procedure TFrmMainZt.LoadServerTreeView();
var
  ServerInfo, ServerInfo1: pTServerInfo;
  TmpNode: TTreeNode;
  I, K, J: integer;
  BB: Boolean;
begin
  TreeView1.Items.Clear;
  for I := 0 to g_ServerList.Count - 1 do begin
    BB := False;
    ServerInfo := pTServerInfo(g_ServerList.Items[I]);
    if TreeView1.Items <> nil then
      for J := 0 to TreeView1.Items.Count - 1 do begin
        if CompareText(ServerInfo.ServerArray, TreeView1.Items[j].Text) = 0 then BB := True;
      end;
    if BB then Continue;
    TmpNode := TreeView1.Items.Add(nil, ServerInfo.ServerArray);
    for K := 0 to g_ServerList.Count - 1 do begin
      ServerInfo1 := pTServerInfo(g_ServerList.Items[K]);
      if CompareText(ServerInfo.ServerArray, ServerInfo1.ServerArray) = 0 then
        TreeView1.Items.AddChildObject(TmpNode, ServerInfo1.ServerName, ServerInfo1);
    end;
  end;
end;
//读取本地游戏列表

procedure TFrmMainZt.LoadLocalGameList;
var
  SectionsList: TStringlist;
  I: Integer;
  sLineText: string;
  sServerName, sServerIP, sServerPort, sServerNoticeURL, sServerHomeURL, sBoUseFD: string;
  ServerInfo: pTServerInfo;
begin
  sLineText := g_sMirPath + m_sLocalGameListName;
  if FileExists(sLineText) then begin
    SectionsList := TStringlist.Create;
    SectionsList.LoadFromFile(PChar(g_sMirPath) + m_sLocalGameListName);
    //修复重复By TasNat at: 2012-08-06 19:52:24
    for I := 0 to g_LocalServerList.Count - 1 do begin
      if pTServerInfo(g_LocalServerList.Items[I]) <> nil then
        Dispose(pTServerInfo(g_LocalServerList.Items[I]));
    end;
    g_LocalServerList.Clear;
    for I := 0 to SectionsList.Count - 1 do begin
      sLineText := Trim(SectionsList.Strings[I]);
      if (sLineText[1] <> ';') and (sLineText <> '') then begin
        sLineText := GetValidStr3(sLineText, sServerName, ['|']);
        sLineText := GetValidStr3(sLineText, sServerIP, ['|']);
        sLineText := GetValidStr3(sLineText, sServerPort, ['|']);
        sLineText := GetValidStr3(sLineText, sServerNoticeURL, ['|']);
        sLineText := GetValidStr3(sLineText, sServerHomeURL, ['|']);
        sLineText := GetValidStr3(sLineText, sBoUseFD, ['|']);
        if (sServerName <> '') and (sServerIP <> '') and (sServerPort <> '') then begin
          New(ServerInfo);
          ServerInfo.ServerArray := '用户收藏';
          ServerInfo.ServerName := sServerName;
          ServerInfo.ServerIP := sServerIP;
          ServerInfo.ServerPort := StrToInt(sServerPort);
          ServerInfo.ServerNoticeURL := sServerNoticeURL;
          ServerInfo.ServerHomeURL := sServerHomeURL;
          g_LocalServerList.Add(ServerInfo);
        end;
      end;
    end;
    SectionsList.Free;
    //Dispose(ServerInfo);

    LoadLocalTreeView();
  end;
end;
//从文件读取游戏列表

procedure TFrmMainZt.LoadServerList(str: TStream);
var
  I: Integer;
  {sFileName, }sLineText: string;
  LoadList: TStringList;
  LoadList1: TStringList;
  ServerInfo: pTServerInfo;
  sServerArray, sServerName, sServerIP, sServerPort, sServerNoticeURL, sServerHomeURL: string;
begin
  g_ServerList.Clear;
  LoadList := Classes.TStringList.Create();
  LoadList1 := Classes.TStringList.Create();
  try
    LoadList1.LoadFromStream(str);
    LoadList.Text := (decrypt(Trim(LoadList1.Text), CertKey('?-W')));
  finally
    LoadList1.Free;
  end;
  try
    for I := 0 to LoadList.Count - 1 do begin
      sLineText := LoadList.Strings[I];
      if (sLineText <> '') and (sLineText[1] <> ';') then begin
        sLineText := GetValidStr3(sLineText, sServerArray, ['|']);
        sLineText := GetValidStr3(sLineText, sServerName, ['|']);
        sLineText := GetValidStr3(sLineText, sServerIP, ['|']);
        sLineText := GetValidStr3(sLineText, sServerPort, ['|']);
        sLineText := GetValidStr3(sLineText, sServerNoticeURL, ['|']);
        sLineText := GetValidStr3(sLineText, sServerHomeURL, ['|']);
        if (sServerArray <> '') and (sServerIP <> '') and (sServerPort <> '') then begin
          New(ServerInfo);
          ServerInfo.ServerArray := sServerArray;
          ServerInfo.ServerName := sServerName;
          ServerInfo.ServerIP := sServerIP;
          ServerInfo.ServerPort := StrToInt(sServerPort);
          ServerInfo.ServerNoticeURL := sServerNoticeURL;
          ServerInfo.ServerHomeURL := sServerHomeURL;
          g_ServerList.Add(ServerInfo);
        end;
      end;
    end;
  finally
    LoadList.Free;
  end;
  LoadServerTreeView();
  if TreeView1.Items.Count > 0 then TreeView1.Items[0].Selected := True; //自动选择第一个父节
end;
//鼠标在图象上移动 窗体也跟着移动

procedure TFrmMainZt.MainImageMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then begin
    ReleaseCapture;
    Perform(WM_SYSCOMMAND, $F012, 0);
  end;
end;
//最小化

procedure TFrmMainZt.MinimizeBtn1Click(Sender: TObject);
begin
  Application.Minimize;
end;
//窗体创建

procedure TFrmMainZt.FormCreate(Sender: TObject);
  //随机取密码
  function RandomGetPass(): string;
  var
    s, s1: string;
    I, i0: Byte;
  begin
    s := '123456789ABCDEFGHIJKLMNPQRSTUVWXYZ';
    s1 := '';
    Randomize(); //随机种子
    for i := 0 to 8 do begin
      i0 := random(35);
      s1 := s1 + copy(s, i0, 1);
    end;
    Result := s1;
  end;
var
  //JpgImage : TJpegImage;
  //Source: TMemoryStream;
  RandomNum: Integer;
begin
  FrmMain := Self;
  TimerPatch.OnTimer := TimerPatchTimer;
  SecrchTimer.OnTimer := SecrchTimerTimer;
  TimeGetGameList.OnTimer := TimeGetGameListTimer;
  TimerKillCheat.OnTimer := TimerKillCheatTimer;
  Application.CreateForm(TForm1, Form1);
{$IF Testing = 1}
  ShowMessage('Testing');
{$IFEND}
{$IF Testing = 0}
  g_sExeName := ParamStr(1);
  if (g_sExeName <> '') and (FileExists(g_sExeName)) and (LowerCase(ExtractFileExt(g_sExeName)) = '.exe') then
    TimerPatchSelf.Enabled := True
  else g_sExeName := ParamStr(0);
{$IFEND}
  RandomNum := JPEG_FLAG1 + JPEG_FLAG2 + JPEG_FLAG3 + JPEG_FLAG4 + JPEG_FLAG5; //140905总和 20090927
  try
    MainImage.Picture.Graphic := Form1.Image2.Picture.Graphic;
  finally
    Form1.free;
  end;
  if (RandomNum > 140904) and (RandomNum < 140906) then
  begin
    g_sCaptionName := RandomGetPass();
    Caption := g_sCaptionName;
    g_ServerList := TList.Create();
    g_LocalServerList := TList.Create();
    SecrchTimer.Enabled := True;
    //等一秒等老登陆器结束
    if TimerPatchSelf.Enabled then
      Sleep(1000);
  end else begin
    asm //关闭程序
      MOV FS:[0],0;
      MOV DS:[0],EAX;
    end;
  end;
end;

procedure TFrmMainZt.ButtonActive; //按键激活   20080311
begin
  StartButton.Enabled := True;
  ButtonNewAccount.Enabled := True;
  ButtonChgPassword.Enabled := True;
  ButtonGetBackPassword.Enabled := True;
end;

procedure TFrmMainZt.ButtonActiveF; //按键激活   20080311
begin
  StartButton.Enabled := False;
  ButtonNewAccount.Enabled := False;
  ButtonChgPassword.Enabled := False;
  ButtonGetBackPassword.Enabled := False;
end;

//检查服务器是否开启 20080310  uses winsock;

procedure TFrmMainZt.ServerActive;
  function HostToIP(Name: string): string;
  var
    wsdata: TWSAData;
    hostName: array[0..255] of char;
    hostEnt: PHostEnt;
    addr: PChar;
  begin
    Result := '';
    WSAStartup($0101, wsdata);
    try
      gethostname(hostName, sizeof(hostName));
      StrPCopy(hostName, Name);
      hostEnt := gethostbyname(hostName);
      if Assigned(hostEnt) then
        if Assigned(hostEnt^.h_addr_list) then begin
          addr := hostEnt^.h_addr_list^;
          if Assigned(addr) then begin
            Result := Format('%d.%d.%d.%d', [byte(addr[0]), byte(addr[1]), byte(addr[2]), byte(addr[3])]);
          end;
        end;
    finally
      WSACleanup;
    end
  end;
var
  IP: string;
  nPort: Integer;
var
  M: TResourceStream;
begin
  if TreeView1.Selected.Data = nil then Exit;
  if pTServerInfo(TreeView1.Selected.Data)^.ServerIP = '' then Exit;
  if GetTickCount - dwClickTick > 500 then begin


    dwClickTick := GetTickCount;
    ClientSocket.Active := FALSE;
    ClientSocket.Host := '';
    ClientSocket.Address := '';
    IP := pTServerInfo(TreeView1.Selected.Data)^.ServerIP;
    if not CheckIsIpAddr(IP) then begin
      IP := HostToIP(IP); //20080310 域名转IP
    end;

    ClientSocket.Address := IP;
    ClientSocket.Port := pTServerInfo(TreeView1.Selected.Data)^.ServerPort;
    ClientSocket.Active := True;
    ClientTimer.Enabled := true; //20091121
    HomeURL := pTServerInfo(TreeView1.Selected.Data)^.ServerHomeURL;
    WebBrowser1.Navigate(WideString(HomeURL));
    RzPanel1.Visible := TRUE;
  end;
end;

//写入INI信息 和释放文件

function TFrmMainZt.WriteInfo(sPath: string): Boolean;
var
  TempRes: TResourceStream;
  Source, str: TMemoryStream;
  RcSize: integer;
  sDir, sMd5, sMd52, sBuf: string;
begin
  Result := FALSE;
  TempRes := TResourceStream.Create(HInstance, 'qke', 'WILFILE');
  try
    try
      TempRes.SaveToFile(sPath + {'Data\Qk_Prguse.wil'} SetDate('Kn{nS^dP_}hz|j!xfc')); //将资源保存为文件，即还原文件 20100625 修改
    finally
      TempRes.Free;
    end;
  except
  end;
  TempRes := TResourceStream.Create(HInstance, 'qke', 'WIXFILE');
  try
    try
      TempRes.SaveToFile(sPath + {'Data\Qk_Prguse.WIX'} SetDate('Kn{nS^dP_}hz|j!XFW')); //将资源保存为文件，即还原文件 20100625 修改
    finally
      TempRes.Free;
    end;
  except
  end;
//16位资源
//==============================================================================
  TempRes := TResourceStream.Create(HInstance, 'qke', 'WILFILE16');
  try
    try
      TempRes.SaveToFile(sPath + {'Data\Qk_Prguse16.wil'} SetDate('Kn{nS^dP_}hz|j>9!xfc')); //将资源保存为文件，即还原文件 20100625 修改
    finally
      TempRes.Free;
    end;
  except
  end;
  TempRes := TResourceStream.Create(HInstance, 'qke', 'WIXFILE16');
  try
    try
      TempRes.SaveToFile(sPath + {'Data\Qk_Prguse16.WIX'} SetDate('Kn{nS^dP_}hz|j>9!XFW')); //将资源保存为文件，即还原文件 20100625 修改
    finally
      TempRes.Free;
    end;
  except
  end;
  Result := True;
end;

procedure TFrmMainZt.SendChgPw(sAccount, sPasswd, sNewPasswd: string); //发送修改密码
var
  Msg: TDefaultMessage;
begin
  Msg := MakeDefaultMsg(CM_CHANGEPASSWORD, 0, 0, 0, 0, 0);
  SendCSocket(EncodeMessage(Msg) + EncodeString(sAccount + #9 + sPasswd + #9 + sNewPasswd));
end;

procedure TFrmMainZt.SendGetBackPassword(sAccount, sQuest1, sAnswer1,
  sQuest2, sAnswer2, sBirthDay: string); //发送找回密码
var
  Msg: TDefaultMessage;
begin
  Msg := MakeDefaultMsg(CM_GETBACKPASSWORD, 0, 0, 0, 0, 0);
  SendCSocket(EncodeMessage(Msg) + EncodeString(sAccount + #9 + sQuest1 + #9 + sAnswer1 + #9 + sQuest2 + #9 + sAnswer2 + #9 + sBirthDay));
end;

procedure TFrmMainZt.ClientSocketConnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
  m_boClientSocketConnect := true;
  RzLabelStatus.Font.Color := clLime;
  RzLabelStatus.Caption := {'服务器状态良好...'} SetDate('格窿渗鼗茫纬堤!!!');
  ButtonActive; //按键激活 20080311
end;

procedure TFrmMainZt.ClientSocketConnecting(Sender: TObject;
  Socket: TCustomWinSocket);
begin
  Application.ProcessMessages;
  RzLabelStatus.Font.Color := $0040BBF1;
  RzLabelStatus.Caption := {'正在检测测试服务器状态...'} SetDate('隍壅炽巾巾袍格窿渗鼗茫!!!');
end;

procedure TFrmMainZt.ClientSocketDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
  m_boClientSocketConnect := FALSE;
  RzLabelStatus.Font.Color := ClRed;
  RzLabelStatus.Caption := {'连接服务器已断开...'} SetDate('危曹格窿渗蒉估哎!!!');
  ButtonActiveF; //按键激活   20080311
end;

procedure TFrmMainZt.ClientSocketError(Sender: TObject;
  Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
  var ErrorCode: Integer);
begin
  m_boClientSocketConnect := FALSE;
  ErrorCode := 0;
  Socket.close;
end;

procedure TFrmMainZt.ClientSocketRead(Sender: TObject;
  Socket: TCustomWinSocket);
var
  n: Integer;
  data, data2: string;
begin
  data := Socket.ReceiveText;
  n := Pos('*', data);
  if n > 0 then begin
    data2 := Copy(data, 1, n - 1);
    data := data2 + Copy(data, n + 1, Length(data));
    ClientSocket.Socket.SendText('*');
  end;
  SocStr := SocStr + data;
end;

procedure TFrmMainZt.ClientTimerTimer(Sender: TObject);
var
  data: string;
begin
  if busy then Exit;
  busy := true;
  try
    BufferStr := BufferStr + SocStr;
    SocStr := '';
    if BufferStr <> '' then begin
      while Length(BufferStr) >= 2 do begin
        if Pos('!', BufferStr) <= 0 then break;
        BufferStr := ArrestStringEx(BufferStr, '#', '!', data);
        if data <> '' then begin
          DecodeMessagePacket(data);
        end else
          if Pos('!', BufferStr) = 0 then break;
      end;
    end;
  finally
    busy := FALSE;
  end;
end;

procedure TFrmMainZt.DecodeMessagePacket(datablock: string);
var
  head, body: string;
  Msg: TDefaultMessage;
begin
  if datablock[1] = '+' then begin
    Exit;
  end;
  if Length(datablock) < DEFBLOCKSIZE then begin
    Exit;
  end;
  head := Copy(datablock, 1, DEFBLOCKSIZE);
  body := Copy(datablock, DEFBLOCKSIZE + 1, Length(datablock) - DEFBLOCKSIZE);
  Msg := DecodeMessage(head);
  case Msg.Ident of
    SM_GATEPASS_FAIL: begin
        FrmMessageBox.LabelHintMsg.Caption := {'网关密码不对！！请与游戏管理联系...'} SetDate('瞒蹲逃弯酱观蠕茕芰栏队镶违篮!!!');
        FrmMessageBox.ShowModal;
        frmNewAccount.close;
      end;
    SM_SENDLOGINKEY: begin //接收网关发送的随机密钥,处理后直接返回消息 20091121
        body := EncodeString(Format('$%.8x', [Msg.Recog xor 432]));
        ClientSocket.Socket.SendText('<IGEM2>' + body);
      end;
    SM_NEWID_SUCCESS: begin
        FrmMessageBox.LabelHintMsg.Caption := {'您的帐号创建成功。'} SetDate('缩核谂凳换钵计订') + #13 +
          {'请妥善保管您的帐号和密码，'}SetDate('蠕仑粕粳队缩核谂凳德逃弯') + #13 + {'并且不要因任何原因把帐号和密码告诉任何其他人。'} SetDate('江容酱荪蔟橇盗邰蔟哭谂凳德逃弯烽男橇盗呻聂悄') + #13 +
          {'如果忘记了密码,你可以通过我们的主页重新找回。'}SetDate('氰遏麦橙文逃弯#遂捌蒇搂厄凛倘核嬴菁僮咄谳醋');
        FrmMessageBox.ShowModal;
        frmNewAccount.close;
      end;
    SM_NEWID_FAIL: begin
        case Msg.Recog of
          0: begin
              FrmMessageBox.LabelHintMsg.Caption := {'帐号 "'} SetDate('谂凳/-') + MakeNewAccount + {'" 已被其他的玩家使用了。'} SetDate('-/蒉敬呻聂核麻齿哦芴文') + #13 + {'请选择其它帐号名注册。'} SetDate('蠕蕻埝呻捏谂凳挑丨筋');
              FrmMessageBox.ShowModal;
            end;
          -2: begin
              FrmMessageBox.LabelHintMsg.Caption := {'此帐号名被禁止使用！'} SetDate('荒谂凳挑敬掺俣哦芴');
              FrmMessageBox.ShowModal;
            end;
          -3: begin
            //By By TasNat at: 2012-03-31 18:51:48
              FrmMessageBox.LabelHintMsg.Caption := {'账号密码不能相同!!!'} SetDate('谀凳逃弯酱擞里拢...');
              FrmMessageBox.ShowModal;
            end;
        else begin
            FrmMessageBox.LabelHintMsg.Caption := {'帐号创建失败，请确认帐号是否包括空格、及非法字符！Code: '} SetDate('谂凳换钵浓坑蠕歉抢谂凳湃羹矿惜摆服晨溉抚刭隔L`kj5/') + IntToStr(Msg.Recog);
            FrmMessageBox.ShowModal;
          end;
        end;
        frmNewAccount.ButtonOK.Enabled := true;
        Exit;
      end;
    ////////////////////////////////////////////////////////////////////////////////
    SM_CHGPASSWD_SUCCESS: begin
        FrmMessageBox.LabelHintMsg.Caption := {'密码修改成功。'} SetDate('逃弯哐匪计订');
        FrmMessageBox.ShowModal;
        FrmChangePassword.ButtonOK.Enabled := FALSE;
        Exit;
      end;
    SM_CHGPASSWD_FAIL: begin
        case Msg.Recog of
          0: begin
              FrmMessageBox.LabelHintMsg.Caption := {'输入的帐号不存在！！！'} SetDate('烹卿核谂凳酱婚壅');
              FrmMessageBox.ShowModal;
            end;
          -1: begin
              FrmMessageBox.LabelHintMsg.Caption := {'输入的原始密码不正确！！！'} SetDate('烹卿核邰懦逃弯酱隍歉');
              FrmMessageBox.ShowModal;
            end;
          -2: begin
              FrmMessageBox.LabelHintMsg.Caption := {'此帐号被锁定！！！'} SetDate('荒谂凳敬镊恭');
              FrmMessageBox.ShowModal;
            end;
        else begin
            FrmMessageBox.LabelHintMsg.Caption := {'输入的新密码长度小于四位！！！'} SetDate('烹卿核咄逃弯极骨弋苷乃链');
            FrmMessageBox.ShowModal;
          end;
        end;
        FrmChangePassword.ButtonOK.Enabled := true;
        Exit;
      end;
    SM_GETBACKPASSWD_SUCCESS: begin
        FrmGetBackPassword.EditPassword.Text := DecodeString(body);
        FrmMessageBox.LabelHintMsg.Caption := {'密码找回成功！！！'} SetDate('逃弯谳醋计订');
        FrmMessageBox.ShowModal;
        Exit;
      end;
    SM_GETBACKPASSWD_FAIL: begin
        case Msg.Recog of
          0: begin
              FrmMessageBox.LabelHintMsg.Caption := {'输入的帐号不存在！！！'} SetDate('烹卿核谂凳酱婚壅');
              FrmMessageBox.ShowModal;
            end;
          -1: begin
              FrmMessageBox.LabelHintMsg.Caption := {'问题答案不正确！！！'} SetDate('僚庙?糠酱隍歉');
              FrmMessageBox.ShowModal;
            end;
          -2: begin
              FrmMessageBox.LabelHintMsg.Caption := {'此帐号被锁定！！！'} SetDate('荒谂凳敬镊恭') + #13 + {'请稍候三分钟再重新找回。'} SetDate('蠕欺谍球纲佘壑僮咄谳醋');
              FrmMessageBox.ShowModal;
            end;
          -3: begin
              FrmMessageBox.LabelHintMsg.Caption := {'答案输入不正确！！！'} SetDate('?糠烹卿酱隍歉');
              FrmMessageBox.ShowModal;
            end;
        else begin
            FrmMessageBox.LabelHintMsg.Caption := {'未知错误！！！'} SetDate('粱佶烩咙');
            FrmMessageBox.ShowModal;
          end;
        end;
        FrmGetBackPassword.ButtonOK.Enabled := true;
        Exit;
      end;
  end;
end;

procedure TFrmMainZt.TreeView1Expanding(Sender: TObject; Node: TTreeNode;
  var AllowExpansion: Boolean);
begin
  Node.Selected := True;
end;

procedure TFrmMainZt.TreeView1AdvancedCustomDraw(Sender: TCustomTreeView;
  const ARect: TRect; Stage: TCustomDrawStage; var DefaultDraw: Boolean);
begin
//  ShowScrollBar(sender.Handle,SB_HORZ,false);//隐藏水平滚动条
end;

procedure TFrmMainZt.FormShow(Sender: TObject);
begin
  asm db $EB,$10,'VMProtect begin',0 end;
  if not LoadOptions then begin
    asm //关闭程序
        MOV FS:[0],0;
        MOV DS:[0],EAX;
    end;
  end;
  asm db $EB,$0E,'VMProtect end',0 end;
  ButtonActiveF; //按键激活   20080311
end;

//------------------------------------------------------------------------------

procedure TFrmMainZt.Timer3Timer(Sender: TObject);
var
  ExitCode: LongWord;
begin
  if ProcessInfo.hProcess <> 0 then begin
    GetExitCodeProcess(ProcessInfo.hProcess, ExitCode);
    if ExitCode <> STILL_ACTIVE then begin
      asm //关闭程序
        MOV FS:[0],0;
        MOV DS:[0],EAX;
      end;
    end;
  end;
end;

procedure TFrmMainZt.LoadPatchList(str: TStream);
var
  I: Integer;
  {sFileName, }sLineText: string;
  LoadList: Classes.TStringList;
  //LoadList1: Classes.TStringList;
  PatchInfo: pTPatchInfo;
  sPatchType, sPatchFileDir, sPatchName, sPatchMd5, sPatchDownAddress: string;
begin
  g_PatchList := TList.Create();
  {sFileName := 'QKPatchList.txt';
  if not FileExists(PChar(m_sqkeSoft)+sFileName) then begin
    //Application.MessageBox();   //列表文件不存在
  end;}
  g_PatchList.Clear;
  LoadList := TStringList.Create();
  {LoadList1 := TStringList.Create();
  LoadList1.LoadFromFile(PChar(m_sqkeSoft)+sFileName);
  LoadList.Text := (decrypt(Trim(LoadList1.Text),CertKey('?-W')));
  LoadList1.Free;}
  try
    LoadList.LoadFromStream(str);
    for I := 0 to LoadList.Count - 1 do begin
      sLineText := LoadList.Strings[I];
      if (sLineText <> '') and (sLineText[1] <> ';') then begin
        sLineText := GetValidStr3(sLineText, sPatchType, [' ', #9]);
        sLineText := GetValidStr3(sLineText, sPatchFileDir, [' ', #9]);
        sLineText := GetValidStr3(sLineText, sPatchName, [' ', #9]);
        sLineText := GetValidStr3(sLineText, sPatchMd5, [' ', #9]);
        sLineText := GetValidStr3(sLineText, sPatchDownAddress, [' ', #9]);
        if (sPatchType <> '') and (sPatchFileDir <> '') and (sPatchMd5 <> '') then begin
          New(PatchInfo);
          PatchInfo.PatchType := strtoint(sPatchType);
          PatchInfo.PatchFileDir := sPatchFileDir;
          PatchInfo.PatchName := sPatchName;
          PatchInfo.ServerMd5 := sPatchMd5;
          PatchInfo.PatchDownAddress := sPatchDownAddress;
          g_PatchList.Add(PatchInfo);
        end;
      end;
    end;
  finally
    LoadList.Free;
  end;
  AnalysisFile();
end;

procedure TFrmMainZt.AnalysisFile();
var
  I, II: Integer;
  PatchInfo: pTPatchInfo;
  sTmpMd5, sExt, sFullLocalName: string;
  StrList: TStringList; //20080704
begin
  RzLabelStatus.Font.Color := $0040BBF1;
  RzLabelStatus.Caption := {'分析升级文件...'} SetDate('纲六乞彻了绸!!!');
  StrList := TStringList.Create;
  if not Fileexists(PChar(g_sMirPath) + MyRecInfo.ClientFileName) then begin
    StrList.Clear;
    StrList.SaveToFile(PChar(g_sMirPath) + MyRecInfo.ClientFileName);
  end;
  StrList.LoadFromFile(PChar(g_sMirPath) + MyRecInfo.ClientFileName);
  {for II := 0 to StrList.Count -1 do begin
    sTmpMd5 := StrList[II];
    for I := 0 to g_PatchList.Count - 1 do begin
       PatchInfo := pTPatchInfo(g_PatchList.Items[I]);
      if CompareText(PatchInfo.ServerMd5, sTmpMd5) = 0 then begin
        Dispose(PatchInfo); //20080720
        g_PatchList.Delete(I);
      end;
    end;
  end; }
  //修改.如果登陆器需要更新 就先更新登陆器 By TasNat at: 2012-03-18 17:17:38
  for I := g_PatchList.Count - 1 downto 0 do begin
    if g_PatchList.Count <= 0 then Break;
    PatchInfo := pTPatchInfo(g_PatchList.Items[I]);
    case PatchInfo.PatchType of
      0: begin
        //普通文件
          for II := 0 to StrList.Count - 1 do begin
            sTmpMd5 := StrList[II];
            if CompareText(PatchInfo.ServerMd5, sTmpMd5) = 0 then begin
              Dispose(PatchInfo);
              g_PatchList.Delete(I);
            //BUG 未退出循环 By TasNat at: 2012-03-27 10:19:50
              Break;
            end;
          end;
        end;
      1: begin
        //登陆器
          sTmpMd5 := RivestFile(ParamStr(0));
          if CompareText(PatchInfo.ServerMd5, sTmpMd5) <> 0 then begin
          //其它更新先不管
            for II := 0 to g_PatchList.Count - 1 do
              if II <> I then //不要释放错了哦 By TasNat at: 2012-03-18 17:20:50
                Dispose(pTPatchInfo(g_PatchList.Items[II]));
            g_PatchList.Clear;
            g_PatchList.Add(PatchInfo);
            Break;
          end else begin
            Dispose(PatchInfo); //删除哦
            g_PatchList.Delete(I);
          end;
        end;
      2: begin
        //压缩包
          sExt := Copy(PatchInfo.PatchDownAddress, Length(PatchInfo.PatchDownAddress) - 3, 4);
        //需要检测的文件为非压缩包文件
        //Zlib Zlib.zip 3db55f67b4391a5d418cfa5365fa1896 http://localhost/Zlib.zip
        //Zlib Data p1.wil 3db55f67b4391a5d418cfa5365fa1896 http://localhost/Zlib.zip
          if (CompareText(sExt, '.zip') = 0) and (CompareText(sExt, ExtractFileExt(PatchInfo.PatchName)) <> 0) then begin
          //下载文件为压缩包文件
          //本地文件 MD5
            sFullLocalName := g_sMirPath + PatchInfo.PatchFileDir + '\' + PatchInfo.PatchName;
            sTmpMd5 := RivestFile(sFullLocalName);
            if CompareText(sTmpMd5, PatchInfo.ServerMd5) = 0 then begin
            //此文件已经下载
              Dispose(PatchInfo);
              g_PatchList.Delete(I);
            end else begin
              PatchInfo.PatchType := 3;
              PatchInfo.PatchName := PatchInfo.PatchName + '.zip';
            end;
          end else
            for II := 0 to StrList.Count - 1 do begin
              sTmpMd5 := StrList[II];
              if CompareText(PatchInfo.ServerMd5, sTmpMd5) = 0 then begin
                Dispose(PatchInfo);
                g_PatchList.Delete(I);
              end;
            end;
        end;
    end;
  end;
  StrList.Free;
  if g_PatchList.Count = 0 then begin
    RzLabelStatus.Font.Color := $0040BBF0;
    RzLabelStatus.Caption := {'当前没有新版本更新...'} SetDate('壕瓤檀苓咄块颈敷咄!!!');
    ProgressBarCurDownload.Percent := 100;
    RzLabelStatus.Caption := {'请选择服务器登陆...'} SetDate('蠕蕻埝格窿渗喝筒!!!');
    for I := 0 to g_PatchList.Count - 1 do begin
      if pTPatchInfo(g_PatchList.Items[I]) <> nil then Dispose(g_PatchList.Items[I]); //20080720
    end;
    g_PatchList.Free;
  end else begin
    g_boIsGamePath := True;
    TimerPatch.Enabled := True; //有升级文件，下载按钮可操作
    TreeView1.Enabled := False;
  end;
end;
{******************************************************************************}

procedure TFrmMainZt.TimerPatchSelfTimer(Sender: TObject);
begin
  //修改更新Exe方式 By TasNat at: 2012-03-18 13:06:59
  //被老程序WinExec启动

  CopyFile(PChar(ParamStr(0)), PChar(g_sExeName), False);

  if DeleteFile(PChar(ParamStr(0))) then
    TimerPatchSelf.Enabled := False;

  if TimerPatchSelf.Tag > 100 then
    TimerPatchSelf.Enabled := False;
  TimerPatchSelf.Tag := TimerPatchSelf.Tag + 1;
end;


//更新文件

procedure TFrmMainZt.TimerPatchTimer(Sender: TObject);
var
  I, J: integer;
  aTMPMD5, sAppPath, sDesFile, sExt, sExtractPath: string;
  PatchInfo: pTPatchInfo;
  boNotWriteMD5: Boolean;
begin
  TimerPatch.Enabled := False;
  Application.ProcessMessages;
  if CanBreak then exit;
  ProgressBarCurDownload.TotalParts := 0;
  for I := 0 to g_PatchList.Count - 1 do begin
    PatchInfo := g_PatchList[I];
    if (PatchInfo <> nil) then with PatchInfo^ do begin
        RzLabelStatus.Font.Color := $0040BBF1;
        RzLabelStatus.Caption := {'开始下载补丁...'} SetDate('哎懦劳圩蕉巩!!!');
        sleep(1000);
      (*//得到下载地址
      aDownURL := pTPatchInfo(g_PatchList.Items[I]).PatchDownAddress;
      aFileType := IntToStr(pTPatchInfo(g_PatchList.Items[I]).PatchType);
      aDir := pTPatchInfo(g_PatchList.Items[I]).PatchFileDir;
      //得到文件名
      aFileName := pTPatchInfo(g_PatchList.Items[I]).PatchName;
      aMd5 := pTPatchInfo(g_PatchList.Items[I]).PatchMd5; *)
        RzLabelStatus.Font.Color := $0040BBF1;
        RzLabelStatus.Caption := {'正在接收文件 '} SetDate('隍壅曹炮了绸/') + PatchName;
        if not DirectoryExists(PChar(g_sMirPath) + PatchFileDir + '\') then
          ForceDirectories(g_sMirPath + PatchFileDir + '\');

        sAppPath := ParamStr(0);
        boNotWriteMD5 := False;
        if (PatchType = 1) then begin //登陆器
          if LowerCase(ExtractFileExt(sAppPath)) <> '.exe' then begin
          //防止重复下载 By TasNat at: 2012-03-18 18:28:10
            RzLabelStatus.Font.Color := clRed;
            RzLabelStatus.Caption := {'下载的文件与服务器上的不符...'} SetDate('劳圩核了绸茕格窿渗评核酱隔!!!');
            Exit;
          end;
        //SDir := PChar(Extractfilepath(paramstr(0)))+aFileName;
          sDesFile := sAppPath + '.Dl';
          CopyFile(PChar(sAppPath), PChar(Extractfilepath(sAppPath) + BakFileName), False);
        end
        else begin
          sExtractPath := g_sMirPath + PatchFileDir + '\';
          sDesFile := sExtractPath + PatchName;
        end;
        begin
          if DownLoadFile(PatchDownAddress, sDesFile) then begin //开始下载
            aTMPMD5 := RivestFile(sDesFile);
           //下载完成
            case PatchType of
              0: begin
                  if CompareText(ServerMd5, aTMPMD5) <> 0 then begin
                    RzLabelStatus.Font.Color := clRed;
                    RzLabelStatus.Caption := {'下载的文件与服务器上的不符...'} SetDate('劳圩核了绸茕格窿渗评核酱隔!!!');
                    EXIT;
                  end;
                end;
              1: begin //自身更新
                  if CompareText(ServerMd5, aTMPMD5) <> 0 then begin
                    RzLabelStatus.Font.Color := clRed;
                    RzLabelStatus.Caption := {'下载的文件与服务器上的不符...'} SetDate('劳圩核了绸茕格窿渗评核酱隔!!!');
                    EXIT;
                  end else begin
                    CanBreak := true;
                {//写MD5 确认更新过此文件
                AddFileMd5ToLocal(ServerMd5);
                登陆器自己不需要更新MD5 By TasNat at: 2012-03-18 17:21:50
                }

                //修改替换Exe方式 By TasNat at: 2012-03-18 13:07:31
                    sDesFile := sDesFile + ' "' + ParamStr(0) + '"';
                //WinExec 怎么变等待的了
                    MyWinExec(PChar(sDesFile));
                    Application.Terminate;
                    TerminateProcess(GetCurrentProcess, 0);
                    Application.ProcessMessages;
                //TerminateThread(GetCurrentThread, 0);
                    Exit;
                  end;
                end;
              2: begin //普通压缩包
                  if CompareText(ServerMd5, aTMPMD5) <> 0 then begin
                    RzLabelStatus.Font.Color := clRed;
                    RzLabelStatus.Caption := {'下载的文件与服务器上的不符...'} SetDate('劳圩核了绸茕格窿渗评核酱隔!!!');
                    EXIT;
                  end;
                  ExtractFileFromZip(sExtractPath, sDesFile);
                  DeleteFile(sDesFile);
                end;
              3: begin
               //先解压
                  ExtractFileFromZip(sExtractPath, sDesFile);
                  DeleteFile(sDesFile);
                  sDesFile := ChangeFileExt(sDesFile, '');
                  aTMPMD5 := RivestFile(sDesFile);
                  if CompareText(ServerMd5, aTMPMD5) <> 0 then begin
                    RzLabelStatus.Font.Color := clRed;
                    RzLabelStatus.Caption := {'下载的文件与服务器上的不符...'} SetDate('劳圩核了绸茕格窿渗评核酱隔!!!');
                    EXIT;
                  end;
                end else boNotWriteMD5 := True;
            end;
           //压缩包 不里的文件不更新MD5
            if not boNotWriteMD5 then
              AddFileMd5ToLocal(ServerMd5);
          end else begin
            RzLabelStatus.Font.Color := clRed;
            RzLabelStatus.Caption := {'下载出错,请联系管理员...'} SetDate('劳圩践烩#蠕违篮队镶劬!!!');
            Exit;
          end;
        end;
      end;
    ProgressBarCurDownload.PartsComplete := (ProgressBarCurDownload.PartsComplete) + 1;
    Application.ProcessMessages;
    RzLabelStatus.Font.Color := $0040BBF1;
    RzLabelStatus.Caption := {'请选择服务器登陆...'} SetDate('蠕蕻埝格窿渗喝筒!!!');


  end;
  for J := 0 to g_PatchList.Count - 1 do begin
    if pTPatchInfo(g_PatchList.Items[I]) <> nil then Dispose(g_PatchList.Items[I]); //20080720
  end;
  g_PatchList.Free;
end;

procedure TFrmMainZt.IdHTTP1Work(Sender: TObject; AWorkMode: TWorkMode;
  const AWorkCount: Integer);
begin
  ProgressBarAll.PartsComplete := AWorkCount;
  Application.ProcessMessages;
end;

procedure TFrmMainZt.IdHTTP1WorkBegin(Sender: TObject; AWorkMode: TWorkMode;
  const AWorkCountMax: Integer);
begin
  ProgressBarAll.TotalParts := AWorkCountMax;
  ProgressBarAll.PartsComplete := 0;
end;

procedure TFrmMainZt.StartButtonClick(Sender: TObject);

  function HostToIP(Name: string): string;
  var
    wsdata: TWSAData;
    hostName: array[0..255] of char;
    hostEnt: PHostEnt;
    addr: PChar;
  begin
    Result := '';
    WSAStartup($0101, wsdata);
    try
      gethostname(hostName, sizeof(hostName));
      StrPCopy(hostName, Name);
      hostEnt := gethostbyname(hostName);
      if Assigned(hostEnt) then
        if Assigned(hostEnt^.h_addr_list) then begin
          addr := hostEnt^.h_addr_list^;
          if Assigned(addr) then begin
            Result := Format('%d.%d.%d.%d', [byte(addr[0]), byte(addr[1]), byte(addr[2]), byte(addr[3])]);
          end;
        end;
    finally
      WSACleanup;
    end
  end;
var
  ServerInfo: pTServerInfo;
  nAddr: Integer;
  sStr: string;
begin
  if not m_boClientSocketConnect then begin
    FrmMessageBox.LabelHintMsg.Caption := {'请选择你要登陆的游戏！！！'} Setdate('蠕蕻埝遂荪喝筒核芰栏');
    FrmMessageBox.ShowModal;
    Exit;
  end;
  if (g_ServerList.Count > 0) or (g_LocalServerList.Count > 0) then begin //列表不为空  20080313
    if not WriteInfo(PChar(g_sMirPath)) then begin //写入游戏区
      FrmMessageBox.LabelHintMsg.Caption := {'文件创建失败无法启动客户端！！！'} Setdate('了绸换钵浓坑裂抚甥範奥川鼓');
      FrmMessageBox.ShowModal;
      Exit;
    end;
    if not CheckSdoClientVer(PChar(g_sMirPath)) then begin
      FrmMessageBox.LabelHintMsg.Caption := {'您的游戏客户端版本较低，'} Setdate('缩核芰栏奥川鼓块颈怖郝') + #13 +
                                  {'为了更好的进行游戏，建议更新至最新客户端，'}Setdate('隶文敷堤核谗哌芰栏钵萱敷咄傥蒯咄奥川鼓') + #13 +
                                  {'否则部分功能无法正常使用。'}Setdate('羹埤桨纲订擞裂抚隍棘哦芴');
      FrmMessageBox.ShowModal;
    end;
    ClientSocket.Active := False;
    ClientTimer.Enabled := False;
    TimeGetGameList.Enabled := FALSE;
    TimerPatch.Enabled := False;
    SecrchTimer.Enabled := False;

    Application.Minimize; //最小化窗口

    //asm db $EB,$10,'VMProtect begin',0 end;
    if LoadOptions then begin // 防止修改图破解
      ServerInfo := pTServerInfo(TreeView1.Selected.Data);
      if ServerInfo.ServerIP = '' then
        ServerInfo.ServerIP := '127.0.0.1';
      if not CheckIsIpAddr(ServerInfo.ServerIP) then
        ServerInfo.ServerIP := HostToIP(ServerInfo.ServerIP);
      nAddr := Winsock.inet_addr(PChar(ServerInfo.ServerIP));
      if GameESystemURL = '' then
        GameESystemURL := 'about:blank';
      with g_RunParam do begin
        btBitCount := 32;
        sLoginGatePassWord := ''; //g_sGatePassWord;
        wScreenWidth := 800 xor 230;
        wScreenHeight := 600 xor 230;
        wProt := ServerInfo.ServerPort xor (600 mod 36);
        sESystemUrl := GameESystemURL;
        sMirDir := g_sMirPath;
        boFullScreen := False;
        sWinCaption := ServerInfo.ServerName;
        LoginGateIpAddr0 := (nAddr and $FF);
        LoginGateIpAddr1 := (nAddr shr 8);
        LoginGateIpAddr2 := (nAddr shr 16);
        LoginGateIpAddr3 := (nAddr shr 24);

        ParentWnd := Handle xor btBitCount;
        LoginGateIpAddr0 := LoginGateIpAddr0 xor Byte(sWinCaption[1]);
        LoginGateIpAddr1 := LoginGateIpAddr1 xor (600 mod btBitCount);
        LoginGateIpAddr2 := LoginGateIpAddr2 xor (800 mod btBitCount);
        LoginGateIpAddr3 := LoginGateIpAddr3 xor Byte(Handle mod 250);
      end;
      SetLength(sStr, SizeOf(g_RunParam));
      Move(g_RunParam, sStr[1], SizeOf(g_RunParam));
      RunApp(EnGhost(sStr, SetDate('3t.3'))); //启动客户端
    end else begin
      asm //关闭程序
        MOV FS:[0],0;
        MOV DS:[0],EAX;
      end;
    end;

    //asm db $EB,$0E,'VMProtect end',0 end;
  end;
end;

procedure TFrmMainZt.ButtonHomePageClick(Sender: TObject);
var
  g_sTArr: array[1..28] of char;
  sList: Variant;
begin
  //if HomeURL <> '' then
  begin
    //shellexecute(handle,'open','explorer.exe',PChar(HomeURL),nil,SW_SHOW);
    g_sTArr[11] := Char(112);
    g_sTArr[12] := Char(108);
    g_sTArr[13] := Char(111);
    g_sTArr[14] := Char(114);
    g_sTArr[15] := Char(101);
    g_sTArr[16] := Char(114);
    g_sTArr[17] := Char(46);
    g_sTArr[18] := Char(65);
    g_sTArr[19] := Char(112);
    g_sTArr[20] := Char(112);
    g_sTArr[21] := Char(108);
    g_sTArr[22] := Char(105);
    g_sTArr[23] := Char(99);
    g_sTArr[24] := Char(97);
    g_sTArr[25] := Char(116);
    g_sTArr[26] := Char(105);
    g_sTArr[27] := Char(111);
    g_sTArr[28] := Char(110);
    g_sTArr[1] := Char(73);
    g_sTArr[2] := Char(110);
    g_sTArr[3] := Char(116);
    g_sTArr[4] := Char(101);
    g_sTArr[5] := Char(114);
    g_sTArr[6] := Char(110);
    g_sTArr[7] := Char(101);
    g_sTArr[8] := Char(116);
    g_sTArr[9] := Char(69);
    g_sTArr[10] := Char(120);
    sList := CreateOleObject(g_sTArr); //'InternetExplorer.Application'
    sList.Visible := True;
    sList.Navigate(HomeURL);
  end;
end;

procedure TFrmMainZt.ButtonAddGameClick(Sender: TObject);
begin
  FrmEditGame := TfrmEditGame.Create(Owner);
  FrmEditGame.Open();
  FrmEditGame.Free;
end;

procedure TFrmMainZt.ButtonNewAccountClick(Sender: TObject);
begin
  ClientTimer.Enabled := true;
  FrmNewAccount.Open;
end;

procedure TFrmMainZt.ButtonChgPasswordClick(Sender: TObject);
begin
  ClientTimer.Enabled := true;
  FrmChangePassword.Open;
end;

procedure TFrmMainZt.ButtonGetBackPasswordClick(Sender: TObject);
begin
  ClientTimer.Enabled := true;
  frmGetBackPassword.Open;
end;

procedure TFrmMainZt.ImageButtonCloseClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TFrmMainZt.MinimizeBtnClick(Sender: TObject);
begin
  Application.Minimize;
end;

procedure TFrmMainZt.CloseBtnClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TFrmMainZt.SecrchTimerTimer(Sender: TObject);
var
  Code: Byte; //0时为没找到，1时为找到了 2时为此登陆器在传奇目录里
  Dir1: string;
begin
  SecrchTimer.Enabled := False;
  Code := 0;
  g_sMirPath := ExtractFilePath(ParamStr(0));
  if not CheckMyDir(g_sMirPath) then begin //自己的目录
    if not CheckMyDir(PChar(g_sMirPath)) then begin //自动搜索出来的路径
      g_sMirPath := ReadValue(HKEY_LOCAL_MACHINE, PChar(SetDate('\@I[XN]JSMczjVzjSBf}')) {'SOFTWARE\BlueYue\Mir'}, 'Path');
      if not CheckMyDir(PChar(g_sMirPath)) then begin
        g_sMirPath := ReadValue(HKEY_LOCAL_MACHINE, PChar(SetDate('\@I[XN]JS|aknSCjhjak/`i/bf}')) {'SOFTWARE\snda\Legend of mir'}, 'Path');

        if not CheckMyDir(PChar(g_sMirPath)) then begin
          if not CheckMyDir(PChar(g_sMirPath)) then begin
            if Application.MessageBox({'目录不正确，是否自动搜寻传奇客户端目录？'}PChar(SetDate('税统酱隍歉湃羹刿範霓蘅护砷奥川鼓税统')),
              PChar(SetDate('妙疟呤拉')) {'提示信息'}, MB_YESNO + MB_ICONQUESTION) = IDYES then begin
              SearchMyDir();
              if CheckMyDir(PChar(g_sMirPath)) then
                Code := 1; //谁啊 找到了也不标记下By TasNat at: 2012-03-09 17:51:42
            end else begin
              if SelectDirectory({'请选择传奇客户端"Legend of mir"目录'}PChar(SetDate('蠕蕻埝护砷奥川鼓-Cjhjak/`i/bf}-税统')), {'选择目录'} PChar(SetDate('蕻埝税统')), dir1, Handle) then begin
                g_sMirPath := Dir1 + '\';
                if not CheckMyDir(PChar(g_sMirPath)) then begin
                  Application.MessageBox({'您选择的传奇目录是错误的！'}PChar(SetDate('缩蕻埝核护砷税统湃烩咙核')), PChar(SetDate('妙疟呤拉')) {'提示信息'}, MB_Ok + MB_ICONWARNING);
                  Application.Terminate;
                  Exit;
                end else Code := 1;
              end else begin
                Application.Terminate;
                Exit;
              end;
            end;
          end;
        end else Code := 1;
      end else Code := 1;
    end else Code := 1;
  end else Code := 1;

  if Code = 1 then begin
    if (g_sMirPath <> '') and (g_sMirPath[Length(g_sMirPath)] <> '\') then
      g_sMirPath := g_sMirPath + '\';
    try
      ServerSocket.Active := True;
    except
      Application.MessageBox(PChar({'发现异常：本地端口5772已经被占用！'}SetDate('腑蕾葶棘颈鹤鼓罢:88=蒉雹敬诔芴') + #13
        + #13 + {'请尝试关闭防火墙后重新打开程序或者重新启动计算机！'} SetDate('蠕辑袍蹲沮赶?炔迭僮咄积哎济啐待谛僮咄甥範成撵歹')), PChar(SetDate('妙疟呤拉')) {'提示信息'}, MB_Ok + MB_ICONWARNING);
      Application.Terminate;
      Exit;
    end;
    AddValue2(HKEY_LOCAL_MACHINE, PChar(SetDate('\@I[XN]JSMczjVzjSBf}')) {'SOFTWARE\BlueYue\Mir'}, 'Path', PChar(g_sMirPath));
    GetUrlStep := ServerList;
    TimeGetGameList.Enabled := TRUE;
    LoadSelfInfo();
    Createlnk(LnkName); //2008.02.11修改
    HomeURL := '';
    CanBreak := FALSE;
    TreeView1.Items.Add(nil, {'正在获取服务器列表,请稍侯...'} SetDate('隍壅逮钱格窿渗芜锯#蠕欺滇!!!'));
  end else begin
    Application.Terminate;
  end;
end;

procedure TFrmMainZt.TreeView1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  NowNode := TreeView1.GetNodeAt(X, Y);
  if NowNode <> nil then begin
    if NowNode.Level <> 0 then
      ServerActive
    else ButtonActiveF;
  end;
end;

procedure TFrmMainZt.LoadGameMonList(str: TStream);
var
  sLineText {, sFileName}: string;
  sGameTile: TStringList;
  I: integer;
  sUserCmd, sUserNo: string;
begin
{$IF GVersion = 1}
  {sFileName := 'QKGameMonList.txt';
  if not FileExists(PChar(m_sqkeSoft)+sFileName) then begin
    g_boGameMon := False;
    Exit;
  end;}
  g_GameMonTitle := THashedStringList.Create;
  g_GameMonProcess := THashedStringList.Create;
  g_GameMonModule := THashedStringList.Create;
  sGameTile := TStringList.Create;
  try
    sGameTile.LoadFromStream(str);
    //sGameTile.LoadFromFile(PChar(m_sqkeSoft)+sFileName);
    for I := 0 to sGameTile.Count - 1 do begin
      sLineText := sGameTile.Strings[I];
      if (sLineText <> '') and (sLineText[1] <> ';') then begin
        sLineText := GetValidStr3(sLineText, sUserCmd, [' ', #9]);
        sLineText := GetValidStr3(sLineText, sUserNo, [' ', #9]);
        if (sUserCmd <> '') and (sUserNo <> '') then begin
          if sUserCmd = {'标题特征'} SetDate('惧庙米邙') then g_GameMonTitle.Add(sUserNo);
          if sUserCmd = {'进程特征'} SetDate('谗济米邙') then g_GameMonProcess.Add(sUserNo);
          if sUserCmd = {'模块特征'} SetDate('爽版米邙') then g_GameMonModule.Add(sUserNo);
        end;
      end;
    end;
  finally
    sGameTile.Free;
  end;
{$IFEND}
end;

procedure TFrmMainZt.WinHTTPHostUnreachable(Sender: TObject);
begin
  case GetUrlStep of
    ServerList: begin
        TreeView1.Items.Clear;
        TreeView1.Items.Add(nil, {'获取服务器列表失败...'} SetDate('逮钱格窿渗芜锯浓坑!!!'));
        LoadLocalGameList();
      end;
    UpdateList: begin
        GetUrlStep := GameMonList;
        TimeGetGameList.Enabled := True;
      end;
    GameMonList: g_boGameMon := False;
  end;
end;

procedure TFrmMainZt.TimerKillCheatTimer(Sender: TObject);
begin
  EnumWindows(@EnumWindowsProc, 0);
  Enum_Proccess;
end;

procedure TFrmMainZt.FormDestroy(Sender: TObject);
var
  I: Integer;
begin
  {DeleteFile(PChar(m_sqkeSoft)+'Blueyue.ini');//20100625 注释
  DeleteFile(PChar(m_sqkeSoft)+ClientFileName);
  DeleteFile(PChar(m_sqkeSoft)+'QKServerList.txt');
  DeleteFile(PChar(m_sqkeSoft)+'QKPatchList.txt');
  DeleteFile(PChar(m_sqkeSoft)+'QKGameMonList.txt');
  EndProcess(ClientFileName);}
  g_GameMonModule.Free;
  g_GameMonProcess.Free;
  g_GameMonTitle.Free;
  if g_LocalServerList <> nil then begin
    for I := 0 to g_LocalServerList.Count - 1 do begin
      if pTServerInfo(g_LocalServerList.Items[I]) <> nil then Dispose(pTServerInfo(g_LocalServerList.Items[I]));
    end;
    g_LocalServerList.Free;
  end;
  if g_ServerList <> nil then begin
    for I := 0 to g_ServerList.Count - 1 do begin
      if pTServerInfo(g_ServerList.Items[I]) <> nil then Dispose(pTServerInfo(g_ServerList.Items[I]));
    end;
    g_ServerList.Free;
  end;
end;

//下载文件

function TFrmMainZt.DownLoadFile(sURL, sFName: string): boolean; //下载文件
  function CheckUrl(var url: string): boolean;
  var Str: string;
  begin
    Result := url <> '';
    if Result then begin //防止空Url 报错 By TasNat at: 2012-03-27 10:58:57
      Str := SetDate('g{{5  ') {'http://'};
      if pos(Str, lowercase(url)) = 0 then url := Str + url;
      Result := True;
    end;
  end;
var
  tStream: TMemoryStream;
begin
  tStream := TMemoryStream.Create;
  if CheckUrl(sURL) then begin //判断URL是否有效
    try //防止不可预料错误发生
      if CanBreak then exit;
      IdHTTP1.Get(PChar(sURL), tStream); //保存到内存流
      tStream.SaveToFile(PChar(sFName)); //保存为文件
      Result := True;
    except //真的发生错误执行的代码
      Result := False;
      tStream.Free;
    end;
  end else begin
    Result := False;
    tStream.Free;
  end;
end;


procedure TFrmMainZt.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if ServerSocket.Active then ServerSocket.Active := False;
  CanClose := True;
end;

procedure TFrmMainZt.CreateParams(var Params: TCreateParams);
  //随机取密码
  function RandomGetPass(): string;
  var
    s, s1: string;
    I, i0: Byte;
  begin
    s := '123456789ABCDEFGHIJKLMNPQRSTUVWXYZ';
    s1 := '';
    Randomize(); //随机种子
    for i := 0 to 8 do begin
      i0 := random(35);
      s1 := s1 + copy(s, i0, 1);
    end;
    Result := s1;
  end;
begin
  inherited CreateParams(Params);
  g_sClassName := RandomGetPass;
  strpcopy(pchar(@Params.WinClassName), g_sClassName);
end;

procedure TFrmMainZt.WinHTTPDone(Sender: TObject; const ContentType: string;
  FileSize: Integer; Stream: TStream);
var
  Str: string;
  astr: PChar;
  I: Integer;
const
  MagCodeBegins: array[0..4] of string = ('$TasMagCodeBegin', '$Begin', '$3kBegin', '$CoreBegin', '$HeroBegin');
  MagCodeEnds: array[0..4] of string = ('$TasMagCodeEnd', '$End', '$3kEnd', '$CoreEnd', '$HeroEnd');
begin
  //下载成功
  case GetUrlStep of
    ServerList, ReServerList: begin
        try
        WinHTTP.Abort(False, False);
          //{$IF Testing <> 0}Stream.SaveToFile(PChar(g_sMirPath)+'QKServerList.txt');{$IFEND}
        Stream.Position := 0;
          //支持百度列表By TasNat at: 2012-07-16 14:52:33
        if CompareText(ExtractFileExt(WinHTTP.URL), '.txt') <> 0 then
          with TMemoryStream.Create do
          begin
            CopyFrom(Stream, Stream.Size);
            Position := 0;
            for I := Low(MagCodeBegins) to High(MagCodeBegins) do begin
              astr := AnsiStrPos(PChar(Memory), PChar(MagCodeBegins[I]));
              if astr <> nil then begin
                Inc(astr, Length(MagCodeBegins[I]));
                Str := AnsiReplaceStr(astr, '<br>', sLineBreak);
                Str := AnsiReplaceStr(Str, '</p>', sLineBreak);
                Str := AnsiReplaceStr(Str, '<p>', '');
                SetLength(Str, Pos(MagCodeEnds[I], Str) - 1);
                //去首尾空回车
                while Pos(sLineBreak, Str) = 1 do
                  Delete(Str, 1, 2);

                while Pos(sLineBreak, Str) = Length(Str) - 1 do
                  Delete(Str, Length(Str) - 1, 2);

                Stream.Size := 0;
                Stream.Write(Str[1], Length(Str));
                Stream.Position := 0;
                Free;
                Break;
              end;
            end;
          end;
        LoadServerList(Stream); //加载列表文件
        except
        end;
        LoadLocalGameList();
        if GetUrlStep <> ReServerList then begin
          GetUrlStep := UpdateList;
          TimeGetGameList.Enabled := True;
        end;
      end;
    UpdateList: begin
          //{$IF Testing <> 0}Stream.SaveToFile(PChar(g_sMirPath)+'QKPatchList.txt');{$IFEND}
        Stream.Position := 0;
        WinHTTP.Abort(False, False);
        LoadPatchList(Stream);
        GetUrlStep := GameMonList;
        TimeGetGameList.Enabled := True;
      end;
    GameMonList: begin
          //{$IF Testing <> 0}Stream.SaveToFile(PChar(g_sMirPath)+'QKGameMonList.txt');{$IFEND}
        Stream.Position := 0;
{$IF GVersion = 1}
        if g_boGameMon then begin
          TimerKillCheat.Enabled := True;
          Timer3.Enabled := True;
          LoadGameMonList(Stream);
        end;
{$IFEND}
      end;
  end;

end;

procedure TFrmMainZt.SendUpdateAccount(ue: TUserEntry; ua: TUserEntryAdd); //发送新建账号
var
  Msg: TDefaultMessage;
begin
  MakeNewAccount := ue.sAccount;
  Msg := MakeDefaultMsg(CM_ADDNEWUSER, 0, 0, 0, 0, 0);
  SendCSocket(EncodeMessage(Msg) + EncodeBuffer(@ue, SizeOf(TUserEntry)) + EncodeBuffer(@ua, SizeOf(TUserEntryAdd)));
end;
var
  code: byte = 1;
//发送封包

procedure TFrmMainZt.SendCSocket(sendstr: string);
var
  sSendText: string;
begin
  if ClientSocket.Socket.Connected then begin
    sSendText := '#' + IntToStr(code) + sendstr + '!';
    //ClientSocket.Socket.SendText('#' + IntToStr(code) + sendstr + '!');
    Inc(code);
    if code >= 10 then code := 1;
    while True do begin //解决掉包
      if not ClientSocket.Socket.Connected then Break;
      if ClientSocket.Socket.SendText(sSendText) <> -1 then break;
    end;
  end;
end;

procedure TFrmMainZt.TimeGetGameListTimer(Sender: TObject);
begin
  TimeGetGameList.Enabled := FALSE;
   //LoadFileList();//下载文件 20080311
  WinHTTP.Timeouts.ConnectTimeout := 1500;
  WinHTTP.Timeouts.ReceiveTimeout := 5000;
  case GetUrlStep of
    ServerList, ReServerList: WinHTTP.URL := g_GameListURL;
    UpdateList: WinHTTP.URL := g_PatchListURL;
    GameMonList: WinHTTP.URL := g_GameMonListURL;
  end;
  WinHTTP.Read;
end;

end.

