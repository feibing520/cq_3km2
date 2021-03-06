unit fmMain;

interface

uses
  Windows, Messages, SysUtils, Graphics,  Forms, Controls, StdCtrls, RSA,
  WinHTTP, JSocket, IdAntiFreezeBase, IdAntiFreeze, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, ExtCtrls, OleCtrls,
  SHDocVw, RzPanel, ComCtrls, ImageProgressbar, RzBmpBtn, RzButton, RzRadChk,
  RzCmboBx, RzPrgres, RzLabel, Classes, Grobal2, Common, GameLoginShare, Main,
  dialogs, Buttons, IniFiles, ComObj,EDcode,EDcodeUnit,Md5,jpeg,Winsock,WinInet, Reg;
  
type
  TFrmMain2 = class(TFrmMain)
    MainImage: TImage;
    MinimizeBtn: TRzBmpButton;
    CloseBtn: TRzBmpButton;
    StartButton: TRzBmpButton;
    ButtonHomePage: TRzBmpButton;
    RzBmpButton2: TRzBmpButton;
    RzBmpButtonCancelPatch: TRzBmpButton;
    ImageButtonClose: TRzBmpButton;
    ButtonGetBackPassword: TRzBmpButton;
    ButtonChgPassword: TRzBmpButton;
    ButtonNewAccount: TRzBmpButton;
    ProgressBarCurDownload: TImageProgressbar;
    ProgressBarAll: TImageProgressbar;
    TreeView1: TTreeView;
    RzCheckBoxFullScreen: TRzCheckBox;
    ClientSocket: TClientSocket;
    ClientTimer: TTimer;
    IdHTTP1: TIdHTTP;
    Timer3: TTimer;
    IdAntiFreeze: TIdAntiFreeze;
    ServerSocket: TServerSocket;
    WinHTTP: TWinHTTP;
    RzComboBox1: TRzComboBox;
    RzCheckBox1: TRzCheckBox;
    RzLabelStatus: TRzLabel;
    ComboBox1: TComboBox;
    RzProgressBarCurDownload: TRzProgressBar;
    RzProgressBarAll: TRzProgressBar;
    RzPanel1: TRzPanel;
    WebBrowser1: TWebBrowser;
    RSA1: TRSA;
    TimerPatchSelf: TTimer;
    TimerReGet: TTimer;
    procedure MainImageMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MinimizeBtn1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TimeGetGameListTimer(Sender: TObject);
    procedure SendCSocket(sendstr: string);
    procedure ClientSocketConnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure WinHTTPHostUnreachable(Sender: TObject);
    procedure StartButtonClick(Sender: TObject);
    procedure ButtonHomePageClick(Sender: TObject);
    procedure ImageButtonCloseClick(Sender: TObject);
    procedure ButtonGetBackPasswordClick(Sender: TObject);
    procedure ButtonChgPasswordClick(Sender: TObject);
    procedure ButtonNewAccountClick(Sender: TObject);
    procedure MinimizeBtnClick(Sender: TObject);
    procedure CloseBtnClick(Sender: TObject);
    procedure RzBmpButton2Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
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
    procedure SecrchTimerTimer(Sender: TObject);
    procedure TreeView1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TimerKillCheatTimer(Sender: TObject);
    procedure Timer3Timer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure WinHTTPDone(Sender: TObject; const ContentType: String;
      FileSize: Integer; Stream: TStream);
    procedure WinHTTPHTTPError(Sender: TObject; ErrorCode: Integer;
      Stream: TStream);
    procedure TimerPatchSelfTimer(Sender: TObject);
    procedure RzBmpButtonCancelPatchClick(Sender: TObject);
    procedure TimerReGetTimer(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    dwClickTick: LongWord;
    procedure WndProc(var Message: TMessage); override;
    procedure AnalysisFile();
    procedure LoadPatchList(str: TStream);
    procedure LoadGameMonList(str: TStream);
    procedure LoadSkinStream(MStream: TMemoryStream);//读皮肤文件
    function DownLoadFile(sURL,sFName: string): boolean;  //下载文件
    function  WriteInfo(sPath: string): Boolean;
    procedure ServerActive;  //20080310
    procedure ButtonActive; //按键激活   20080311

//    procedure SetConfigs();
  public
    procedure LoadServerList(str: TStream);
    procedure LoadServerTreeView();
    procedure ButtonActiveF; //按键激活   20080311
    procedure SendUpdateAccount(ue: TUserEntry; ua: TUserEntryAdd); override; //发送新建账号
    procedure SendChgPw(sAccount, sPasswd, sNewPasswd: string); override; //发送修改密码
    procedure SendGetBackPassword(sAccount, sQuest1, sAnswer1, sQuest2, sAnswer2, sBirthDay: string); override; //发送找回密码
    procedure CreateParams(var Params:TCreateParams);override;//设置程序的类名 20080412
    procedure LoadServerListView();
    procedure LoadSelfInfo();
    procedure OnExcept(Sender: TObject; E: Exception);
  protected
    procedure SetEnabledServerList(Value: Boolean); override;
    procedure SetStatusString(const Value: string); override;
    procedure SetStatusColor(const Value: TColor); override;
  end;
  TThreadFD = class(TThread)
  private
    FModId : Integer;
    FPort: Integer;
    FIP : string;
    FLib: string;
  protected
    procedure Execute; override;
  end;
  procedure WaitAndPass (msec: longword);
var
  FrmMain2: TFrmMain2;
  NowNode : TTreeNode = nil;
  GetUrlStep: TGetUrlStep;
  g_GameItemsURL: string;
 {$if GVersion = 0}
 GameListURL: pchar ='http://127.0.0.1/QKServerList.txt';
 sPatchListURL1: PChar = 'http://127.0.0.1/QKPatchList.txt';
 GameESystemURL: pchar ='http://www.56m2.com';
 {$ifend}
  boIsCheck: Boolean = False;
implementation
uses GetBackPassword, Secrch, MsgBox, GameMon, Zlib, uFileUnit, HUtil32,NewAccount,
     ChangePassword, uTasBMPFIle, uRes, StrUtils;
{$R *.dfm}

procedure TFrmMain2.SetEnabledServerList(Value: Boolean);
begin
  TreeView1.Enabled := Value;
end;

procedure TFrmMain2.SetStatusString(const Value: string);
begin
  RzLabelStatus.Caption := Value;
end;

procedure TFrmMain2.SetStatusColor(const Value: TColor);
begin
  RzLabelStatus.Font.Color := Value;
end;

procedure WaitAndPass (msec: longword);
var
   start: longword;
begin
   start := GetTickCount;
   while GetTickCount - start < msec do begin
      Application.ProcessMessages;
   end;
end;

procedure DeCompressStream(CompressedStream: TMemoryStream);
var
  MS: TDecompressionStream;
  Buffer: PChar;
  Count: int64;
begin
  if CompressedStream.Size <= 0 then exit;
  CompressedStream.Position := 0; //复位流指针
  CompressedStream.ReadBuffer(Count, SizeOf(Count));
  //从被压缩的文件流中读出原始的尺寸
  GetMem(Buffer, Count); //根据尺寸大小为将要读入的原始流分配内存块
  MS := TDecompressionStream.Create(CompressedStream);
  try
    MS.ReadBuffer(Buffer^, Count);
    //将被压缩的流解压缩，然后存入 Buffer内存块中
    CompressedStream.Clear;
    CompressedStream.WriteBuffer(Buffer^, Count); //将原始流保存至 MS流中
    CompressedStream.Position := 0; //复位流指针
  finally
    FreeMem(Buffer);
    MS.Free;//20110714
  end;
end;

procedure TFrmMain2.OnExcept(Sender: TObject; E: Exception);
begin
  if g_Except = nil then
    g_Except := TStringList.Create;
  g_Except.Add(E.Message);
end;

procedure TFrmMain2.WinHTTPHTTPError(Sender: TObject; ErrorCode: Integer;
  Stream: TStream);
begin
  case GetUrlStep of
    ServerList: begin
      if DownCode = 2 then begin
        if g_FileHeader.boServerList then begin //TreeView样式
          TreeView1.Items.Clear;
          TreeView1.Items.Add(nil,{'获取服务器列表失败...'}SetDate('逮钱格窿渗芜锯浓坑!!!'));
        end else begin //ComboBox样式
          ComboBox1.Items.Clear;
          ComboBox1.Items.Add({'获取服务器列表失败...'}SetDate('逮钱格窿渗芜锯浓坑!!!'));
          ComboBox1.ItemIndex := 0;
        end;
      end else begin
        DownCode := 2;
        TimeGetGameList.Enabled := True;
        if g_FileHeader.boServerList then begin
          TreeView1.Items.Clear;
          TreeView1.Items.Add(nil,{'正在获取备用服务器列表,请稍侯...'}SetDate('隍壅逮钱痉芴格窿渗芜锯#蠕欺滇!!!'));
        end else begin
          ComboBox1.Items.Clear;
          ComboBox1.Items.Add({'正在获取备用服务器列表,请稍侯...'}SetDate('隍壅逮钱痉芴格窿渗芜锯#蠕欺滇!!!'));
          ComboBox1.ItemIndex := 0;
        end;
      end;
    end;
    UpdateList: begin
      GetUrlStep := GameMonList;
      TimeGetGameList.Enabled := True;
    end;
    GameMonList: {$IF GVersion = 1}g_boGameMon := False;{$IFEND}
  end;
end;


//把信息添假到树型列表里
procedure TFrmMain2.LoadServerTreeView();
var
  ServerInfo,ServerInfo1: pTServerInfo;
  TmpNode: TTreeNode;
  I,K,J:integer;
  BB:Boolean;
begin
   TreeView1.Items.Clear;
   for I := 0 to g_ServerList.Count - 1 do begin
    BB:=False;
    ServerInfo := pTServerInfo(g_ServerList.Items[I]);
    if TreeView1.Items<> nil then
    for J:=0 to TreeView1.Items.Count-1 do begin
       if CompareText(ServerInfo.ServerArray,TreeView1.Items[j].Text)=0 then BB:=True;
    end;
     if BB then Continue;
     TmpNode := TreeView1.Items.Add(nil,ServerInfo.ServerArray);
      for K := 0 to g_ServerList.Count - 1 do  begin
      ServerInfo1 := pTServerInfo(g_ServerList.Items[K]);
       if CompareText(ServerInfo.ServerArray,ServerInfo1.ServerArray)=0 then
         TreeView1.Items.AddChildObject(TmpNode,ServerInfo1.ServerName,ServerInfo1);
      end;
   end;
end;

//从文件读取游戏列表
procedure TFrmMain2.LoadServerList(str: TStream);
var
  I: Integer;
  sLineText, sCheckPort ,sCheckMode: string;
  LoadList: TStringList;
  ServerInfo: pTServerInfo;
  sServerArray, sServerName, sServerIP, sServerPort, sServerNoticeURL, sServerHomeURL: string;
  sGameItemsURL: string;
  sGatePass: string;
begin
  g_ServerList.Clear;
  LoadList := Classes.TStringList.Create();
  try
  LoadList.LoadFromStream(str);
  if LoadList.Text <> '' then begin
    for I := 0 to LoadList.Count - 1 do begin
      sLineText := LoadList.Strings[I];
      if (sLineText <> '') and (sLineText[1] <> ';') then begin
        sLineText := GetValidStr3(sLineText, sServerArray, ['|']);
        sLineText := GetValidStr3(sLineText, sServerName, ['|']);
        sLineText := GetValidStr3(sLineText, sServerIP, ['|']);
        sLineText := GetValidStr3(sLineText, sServerPort, ['|']);
        sLineText := GetValidStr3(sLineText, sServerNoticeURL, ['|']);
        sLineText := GetValidStr3(sLineText, sServerHomeURL, ['|']);
        sLineText := GetValidStr3(sLineText, sGameItemsURL, ['|']);
        sLineText := GetValidStr3(sLineText, sGatePass, ['|']);
        sLineText := GetValidStr3(sLineText, sCheckPort, ['|']);
        sLineText := GetValidStr3(sLineText, sCheckMode, ['|']);

        if (sServerArray <> '') and (sServerIP <> '') and (sServerPort <> '') then begin
          New(ServerInfo);
          ServerInfo.Gatepass := sGatePass;
          ServerInfo.ServerArray := sServerArray;
          ServerInfo.ServerName := sServerName;
          ServerInfo.ServerIP := sServerIP;
          ServerInfo.ServerPort := StrToInt(sServerPort);
          ServerInfo.CheckPort := Str_ToInt(sCheckPort, -1);
          ServerInfo.CheckMode := Str_ToInt(sCheckMode, 1);
          ServerInfo.ServerNoticeURL := sServerNoticeURL;
          ServerInfo.ServerHomeURL := sServerHomeURL;
          ServerInfo.GameItemsURL := sGameItemsURL;
          g_ServerList.Add(ServerInfo);
        end;
      end;
    end;
  end;
  finally
    LoadList.Free;
  end;
  if g_FileHeader.boServerList then begin
    LoadServerTreeView();
    //增加分析列表失败给提示 By TasNat at: 2012-04-03 16:11:48
    if (g_ServerList.Count < 1) and (LoadList.Count > 0) then begin
      TreeView1.Items.Clear;
      TreeView1.Items.Add(nil,{'分析服务器列表失败...'}SetDate('纲六格窿渗芜锯浓坑!!!'));
    end;
    if TreeView1.Items.Count > 0 then TreeView1.Items[0].Selected := True;   //自动选择第一个父节
  end else begin
    LoadServerListView();
    if (g_ServerList.Count < 1) and (LoadList.Count > 0) then begin
      ComboBox1.Items.Clear;
      ComboBox1.Items.Add({'分析服务器列表失败...'}SetDate('纲六格窿渗芜锯浓坑!!!'));
      ComboBox1.ItemIndex := 0;
    end;
  end;
end;

//鼠标在图象上移动 窗体也跟着移动
procedure TFrmMain2.MainImageMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then begin
    ReleaseCapture;
    Perform(WM_SYSCOMMAND, $F012, 0);
  end;
end;

//最小化
procedure TFrmMain2.MinimizeBtn1Click(Sender: TObject);
begin
  Application.Minimize;
end;

//窗体创建
procedure TFrmMain2.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanBreak := True;
end;

procedure TFrmMain2.FormCreate(Sender: TObject);
  //随机取密码
  function RandomGetPass():string;
  var
    s,s1:string;
    I,i0:Byte;
  begin
      s:='123456789ABCDEFGHIJKLMNPQRSTUVWXYZ';
      s1:='';
      Randomize(); //随机种子
      for i:=0 to 8 do begin
        i0:=random(35);
        s1:=s1+copy(s,i0,1);
      end;
      Result := s1;
  end;
var
  Source,str:TMemoryStream;
begin
  FrmMain := Self;
  TimerPatch.OnTimer := TimerPatchTimer;
  SecrchTimer.OnTimer := SecrchTimerTimer;
  TimeGetGameList.OnTimer := TimeGetGameListTimer;
  TimerKillCheat.OnTimer := TimerKillCheatTimer;

  {$IF Testing <> 0}
  g_sMirPath := 'E:\热血传奇New\';
  CheckAndDownNeedFile;
  {$ifend}
  Application.OnException :=  OnExcept;
  g_sExeName := ParamStr(0);
  if CompareText(ExtractFileExt(g_sExeName), '.exe') <> 0 then
    g_sExeName := ParamStr(1);
  if CompareText(ExtractFileExt(g_sExeName), '.exe') <> 0 then
    g_sExeName := ChangeFileExt(g_sExeName, '.exe');
  g_sCaptionName := RandomGetPass();
  Caption := g_sCaptionName;
  LoadSelfInfo();
  if (MyRecInfo.MainImagesFileSize > 0) then begin
    Source:=TMemoryStream.Create;
    str := TMemoryStream.Create;
    try //读取主窗体的图片
      (*IsNum('123');//20110719
      {$IF  Testing =1}
      Source.LoadFromFile('C:\1.exe');
     {$Else}
      Source.LoadFromFile(Application.ExeName);
      {$ifend}
      IsNum('456');//20110719
      Source.Seek(MyRecInfo.SourceFileSize,soFromBeginning);

      IsNum('789');//20110719
      str.CopyFrom(Source, MyRecInfo.MainImagesFileSize);
      *)
      LoadResToMemStream(str);
      str.SetSize(MyRecInfo.MainImagesFileSize);
      DeCompressStream(str);//解压流
      str.Position:= 0;
      DecryptToStream(str, 'dfgt542');//流解密
      str.Position:= 0;
      LoadSkinStream(str);
    finally
      str.Free;
      Source.Free;
    end;
  end;
  {$IF GVersion = 0}
  g_FileHeader.boServerList := True;
  g_NormalLabelColor := clBlack;
  {$IFEND}
  g_ServerList := TList.Create(); //20080313
  SecrchTimer.Enabled := True;
   //挂上键盘钩子
  //hhkNTKeyboard := SetWindowsHookEx(WH_KEYBOARD_LL, LowLevelKeyboardFunc, HInstance, 0);
end;

procedure TFrmMain2.ButtonActive; //按键激活   20080311
begin
  StartButton.Enabled := True;
  ButtonNewAccount.Enabled := True;
  ButtonChgPassword.Enabled := True;
  ButtonGetBackPassword.Enabled := True;
end;

procedure TFrmMain2.ButtonActiveF; //按键激活   20080311
begin
  StartButton.Enabled := False;
  ButtonNewAccount.Enabled := False;
  ButtonChgPassword.Enabled := False;
  ButtonGetBackPassword.Enabled := False;
end;
type

  TLogin3kFw = function(Ver: Integer; Wait: Boolean; IP: PChar; Port: Integer; ModId: Integer): DWORD; stdcall;

  {
    参数说明  Ver   固定值： 351828518
              Wait  为是否等待验证完成函数才返回。如果为False ，执行函数立即完成返回.如果为true 则TLogin3kFw函数返回1表示验证OK。0为失败。
              IP 为服务器IP地址
              Port  为防火墙登陆器采集端口
              ModId 为验证方式  验证方式: 0 使用PING模式, 1 是TCP模式, 2 是PING +TCP ,3 是TCP+PING.建议使用 1

  }
function RunFD(    FModId : Integer;
    FPort: Integer;
    FIP : string;
    FLib: string) : Integer;
var
  GetPluginInfo: TLogin3kFw;
  sFunName : string;
  HLib : THandle;
begin
  HLib := LoadLibrary(PChar(FLib));
  sFunName := SetDate('C`hfa<dIx');
  if HLib > 0 then begin
    try
    @GetPluginInfo := GetProcAddress(HLib, PChar(sFunName));
    if Assigned(GetPluginInfo) then begin
      //RzLabelStatus.Caption := '开始';
      Result := GetPluginInfo(351828518, True, PChar(FIP), FPort, FModId);
    //end else begin
    //  ShowMessage(sFunName + ':函数获取失败' + SysErrorMessage(GetLastError));
    end;
    finally
      FreeLibrary(HLib);
    end;
  end;//   else ShowMessage('加载风盾失败');
end;

procedure TThreadFD.Execute;
begin
  RunFD(FModId, FPort, FIP, FLib);
end;

//检查服务器是否开启 20080310  uses winsock;
procedure TFrmMain2.ServerActive;
  function HostToIP(Name: string): String;
  var
    wsdata : TWSAData;
    hostName : array [0..255] of char;
    hostEnt : PHostEnt;
    addr : PChar;
  begin
    Result := '';
    WSAStartup ($0101, wsdata);
    try
      gethostname (hostName, sizeof (hostName));
      StrPCopy(hostName, Name);
      hostEnt := gethostbyname (hostName);
      if Assigned (hostEnt) then
        if Assigned (hostEnt^.h_addr_list) then begin
          addr := hostEnt^.h_addr_list^;
          if Assigned (addr) then begin
            Result := Format ('%d.%d.%d.%d', [byte(addr [0]),byte(addr [1]), byte(addr [2]),byte(addr [3])]);
          end;
      end;
    finally
      WSACleanup;
    end
  end;
  procedure WriteDll;
  var
    Source ,str: TMemoryStream;
    RcSize : Integer;
  begin
    try
    g_boUsesFD := MyRecInfo.FDDllFileSize > 0;
  if g_boUsesFD then begin//内挂文件 20110305
    Source:=TMemoryStream.Create;
    str:=TMemoryStream.Create;
    try //读取文件
      try
        (*
        {$IF Testing <> 0}
        Source.LoadFromFile('C:\1.exe');
        {$ELSE}
        Source.LoadFromFile(Application.ExeName);
        {$ifend}
        *)
        LoadResToMemStream(Source);
        RcSize:= MyRecInfo.SourceFileSize + MyRecInfo.MainImagesFileSize +
                 MyRecInfo.TzHintListFileSize + MyRecInfo.PulsDescFileSize +
                 MyRecInfo.GameSdoFilterFileSize;
        IsNum('706');//20110719
        Source.Seek(RcSize,soFromBeginning);
        IsNum('120');//20110719
        str.CopyFrom(Source, MyRecInfo.FDDllFileSize);
        DeCompressStream(str);//解压流
        str.Position:= 0;
        IsNum('120');
        //if not FileExists(g_sMirPath+Setdate('n|in!kcc')) then
          str.SaveToFile(g_sMirPath+Setdate('n|in!kcc'));
        {else begin

        end; }
      except
      end;
    finally
      str.Free;
      Source.Free;
    end;
  end;
    except
       g_boUsesFD := False;
    end;
  end;
var
  IP:String;
  nPort : Integer;
  ModId : Integer;
  TT : TThreadFD;
  ServerInfo : pTServerInfo;
var
  M : TResourceStream;
begin
  ServerInfo := nil;
  if g_FileHeader.boServerList then begin //TreeView样式
    if TreeView1.Selected = nil then Exit;
    ServerInfo := pTServerInfo(TreeView1.Selected.Data);
  end else begin
    if (ComboBox1.ItemIndex < 0 ) or (ComboBox1.ItemIndex > ComboBox1.Items.Count) then Exit;
    ServerInfo := pTServerInfo(ComboBox1.Items.Objects[ComboBox1.ItemIndex]);
  end;
  if ServerInfo = nil then Exit;

    if ServerInfo.ServerIP = '' then Exit;
    if GetTickCount - dwClickTick > 500 then begin
      dwClickTick := GetTickCount;
      ClientSocket.Active := FALSE;
      ClientSocket.Host := '';
      ClientSocket.Address := '';
      IP := ServerInfo.ServerIP;
      if not CheckIsIpAddr(IP) then begin
        IP:= HostToIP(IP);//20080310 域名转IP
      end;
      nPort := ServerInfo.CheckPort;
      if nPort > 1 then begin

      WriteDll;
      if g_boUsesFD then
      begin

       ModId := ServerInfo.CheckMode;
         RunFD(ModId, nPort, IP, g_sMirPath+Setdate('n|in!kcc'));
        {try
          TT := TThreadFD.Create(True);
          TT.FModId := ModId;
          TT.FPort := nPort;
          TT.FIP := IP;
          TT.FLib := g_sMirPath+Setdate('n|in!kcc');
          TT.FreeOnTerminate := True;
          TT.Resume;
          nPort := GetTickCount + 3000;
          while (GetTickCount < nPort) and (not Application.Terminated) and (not TT.Terminated) do begin
            Application.ProcessMessages;
            Sleep(10);
          end;
        except
        end; }

      end;//   else ShowMessage('未起用风盾2');
      end;// else ShowMessage('未起用风盾');

      ClientSocket.Address := IP;
      ClientSocket.Port := ServerInfo.ServerPort;
      ClientSocket.Active := True;
      ClientTimer.Enabled := true;//20091121
      g_sHomeURL := ServerInfo.ServerHomeURL;
      g_GameItemsURL := ServerInfo.GameItemsURL;
      WebBrowser1.Navigate(WideString(ServerInfo.ServerNoticeURL));
      RzPanel1.Visible:=TRUE;
    end;
end;

//写入INI信息 和释放文件
function TFrmMain2.WriteInfo(sPath: string): Boolean;
var
  TempRes: TResourceStream;
  Source,str:TMemoryStream;
  RcSize:integer;
begin
  Result := FALSE;
  TempRes := TResourceStream.Create(HInstance,SetDate('~dj'),PChar(SetDate('XFCIFCJ')));
  try
    try
      TempRes.SaveToFile(sPath +{'Data\Qk_Prguse.wil'}SetDate('Kn{nS^dP_}hz|j!xfc')); //将资源保存为文件，即还原文件 20100625 修改
    finally
      TempRes.Free;
    end;
  except
  end;
  TempRes := TResourceStream.Create(HInstance,SetDate('~dj'), PChar(SetDate('XFWIFCJ')));
  try
    try
      TempRes.SaveToFile(sPath +{'Data\Qk_Prguse.WIX'}SetDate('Kn{nS^dP_}hz|j!XFW')); //将资源保存为文件，即还原文件 20100625 修改
    finally
      TempRes.Free;
    end;
  except
  end;
//16位资源
  TempRes := TResourceStream.Create(HInstance,SetDate('~dj'),PChar(SetDate('XFCIFCJ>9')));
  try
    try
      TempRes.SaveToFile(sPath +{'Data\Qk_Prguse16.wil'}SetDate('Kn{nS^dP_}hz|j>9!xfc')); //将资源保存为文件，即还原文件 20100625 修改
    finally
      TempRes.Free;
    end;
  except
  end;
  TempRes := TResourceStream.Create(HInstance,SetDate('~dj'), PChar(SetDate('XFWIFCJ>9')));
  try
    try
      TempRes.SaveToFile(sPath +{'Data\Qk_Prguse16.WIX'}SetDate('Kn{nS^dP_}hz|j>9!XFW')); //将资源保存为文件，即还原文件 20100625 修改
    finally
      TempRes.Free;
    end;
  except
  end;
//==============================================================================
  if MyRecInfo.TzHintListFileSize > 0 then begin//套装文件大小 20110305
    Source:=TMemoryStream.Create;
    str:=TMemoryStream.Create;
    try //读取套装文件
      try
        (*
        {$IF  Testing =1}
         Source.LoadFromFile('C:\1.exe');
        {$Else}
         Source.LoadFromFile(Application.ExeName);
         {$ifend}
        *)
        LoadResToMemStream(Source);
        RcSize:= MyRecInfo.SourceFileSize + MyRecInfo.MainImagesFileSize;
        IsNum('456');//20110719
        Source.Seek(RcSize,soFromBeginning);
        IsNum('256');//20110719
        str.CopyFrom(Source, MyRecInfo.TzHintListFileSize);
        DeCompressStream(str);//解压流
        str.Position:= 0;
        str.SaveToFile(PChar(g_sMirPath)+Setdate(TzHintList));//TzHintList.txt 保存套装文件
      except
      end;
    finally
      str.Free;
      Source.Free;
    end;
  end;

  if MyRecInfo.PulsDescFileSize > 0 then begin//经络文件大小 20110305
    Source:=TMemoryStream.Create;
    str:=TMemoryStream.Create;
    try //读取文件
      try
        (*{$IF  Testing =1}
      Source.LoadFromFile('C:\1.exe');
     {$Else}
      Source.LoadFromFile(Application.ExeName);
      {$ifend}
      *)
      LoadResToMemStream(Source);
        RcSize:= MyRecInfo.SourceFileSize + MyRecInfo.MainImagesFileSize + MyRecInfo.TzHintListFileSize;
        IsNum('786');//20110719
        Source.Seek(RcSize,soFromBeginning);
        IsNum('436');//20110719
        str.CopyFrom(Source, MyRecInfo.PulsDescFileSize);
        DeCompressStream(str);//解压流
        str.Position:= 0;
        str.SaveToFile(sPath +{'Data\PulsDesc.dat'}Setdate('Kn{nS_zc|Kj|l!kn{'));//保存经络文件PulsDesc.txt
      except
      end;
    finally
      str.Free;
      Source.Free;
    end;
  end;

  if MyRecInfo.GameSdoFilterFileSize > 0 then begin//内挂文件 20110305
    Source:=TMemoryStream.Create;
    str:=TMemoryStream.Create;
    try //读取文件
      try
        (*{$IF  Testing =1}
      Source.LoadFromFile('C:\1.exe');
     {$Else}
      Source.LoadFromFile(Application.ExeName);
      {$ifend}
      *)
        LoadResToMemStream(Source);
        RcSize:= MyRecInfo.SourceFileSize + MyRecInfo.MainImagesFileSize + MyRecInfo.TzHintListFileSize + MyRecInfo.PulsDescFileSize;
        IsNum('706');//20110719
        Source.Seek(RcSize,soFromBeginning);
        IsNum('120');//20110719
        str.CopyFrom(Source, MyRecInfo.GameSdoFilterFileSize);
        DeCompressStream(str);//解压流
        str.Position:= 0;
        str.SaveToFile(PChar(g_sMirPath)+Setdate(FilterItemNameList));//FilterItemNameList.dat
      except
      end;
    finally
      str.Free;
      Source.Free;
    end;
  end;
  g_boUsesFD := MyRecInfo.FDDllFileSize > 0;
  if g_boUsesFD then begin//内挂文件 20110305
    Source:=TMemoryStream.Create;
    str:=TMemoryStream.Create;
    try //读取文件
      try
        (*{$IF  Testing =1}
      Source.LoadFromFile('C:\1.exe');
     {$Else}
      Source.LoadFromFile(Application.ExeName);
      {$ifend}
      *)
        LoadResToMemStream(Source);
        RcSize:= MyRecInfo.SourceFileSize + MyRecInfo.MainImagesFileSize + MyRecInfo.TzHintListFileSize + MyRecInfo.PulsDescFileSize + MyRecInfo.GameSdoFilterFileSize;
        IsNum('706');//20110719
        Source.Seek(RcSize,soFromBeginning);
        IsNum('120');//20110719
        str.CopyFrom(Source, MyRecInfo.FDDllFileSize);
        DeCompressStream(str);//解压流
        str.Position:= 0;
        IsNum('120');//20110719
        str.SaveToFile(g_sMirPath+Setdate('n|in!kcc'));//FilterItemNameList.dat
      except
      end;
    finally
      str.Free;
      Source.Free;
    end;
  end;
  Result := true;
end;

procedure TFrmMain2.SendChgPw(sAccount, sPasswd, sNewPasswd: string); //发送修改密码
var
  Msg: TDefaultMessage;
begin
  Msg := MakeDefaultMsg(CM_CHANGEPASSWORD, 0, 0, 0, 0, 0);  //20081210
  SendCSocket(EncodeMessage(Msg) + EncodeString(sAccount + #9 + sPasswd + #9 + sNewPasswd));
end;

procedure TFrmMain2.SendGetBackPassword(sAccount, sQuest1, sAnswer1,
  sQuest2, sAnswer2, sBirthDay: string); //发送找回密码
var
  Msg: TDefaultMessage;
begin
  Msg := MakeDefaultMsg(CM_GETBACKPASSWORD, 0, 0, 0, 0, 0);//20081210
  SendCSocket(EncodeMessage(Msg) + EncodeString(sAccount + #9 + sQuest1 + #9 + sAnswer1 + #9 + sQuest2 + #9 + sAnswer2 + #9 + sBirthDay));
end;

procedure TFrmMain2.ClientSocketConnect(Sender: TObject;
  Socket: TCustomWinSocket);
  //随机取名
  function RandomGetName():string;
  var
    s,s1:string;
    I,i0:integer;
  begin
      s:='123456789ABCDEFGHIJKLMNPQRSTUVWXYZ';
      s1:='';
      Randomize(); //随机种子
      for i:=0 to 10 do begin
        i0:=random(35);
        s1:=s1+copy(s,i0,1);
      end;
      Result := s1;
  end;
var
  pServerList: Pointer;
begin
  pServerList := nil;
  if g_FileHeader.boServerList then begin
    if TreeView1.Selected <> nil then
    pServerList := TreeView1.Selected.Data;
  end else begin
    pServerList := ComboBox1.Items.Objects[ComboBox1.ItemIndex];
  end;
  if pServerList = nil then Exit;
  m_boClientSocketConnect := true;
  RzLabelStatus.Font.Color := g_ConnectLabelColor;//clLime;
  RzLabelStatus.Caption := {'服务器状态良好...'}SetDate('格窿渗鼗茫纬堤!!!');
  {修改为发送CM_SELECTSERVER 的时候发送密码By TasNat at: 2012-11-22 15:18:59
  if pTServerInfo(pServerList)^.GatePass <> '' then begin//发送密码到网关上 认证
    ClientSocket.Socket.SendText ('<56m2>' + EncodeString(Encrypt(RandomGetName(), CertKey('?-W'))));
  end;}

  ButtonActive; //按键激活 20080311
end;

procedure TFrmMain2.ClientSocketConnecting(Sender: TObject;
  Socket: TCustomWinSocket);
begin
  RzLabelStatus.Font.Color := g_NormalLabelColor;
  RzLabelStatus.Caption := {'正在检测测试服务器状态...'}SetDate('隍壅炽巾巾袍格窿渗鼗茫!!!');
  Application.ProcessMessages;
end;

procedure TFrmMain2.ClientSocketDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
  m_boClientSocketConnect := FALSE;
  RzLabelStatus.Font.Color := g_DisconnectLabelColor;//ClRed;
  RzLabelStatus.Caption := {'连接服务器已断开...'}SetDate('危曹格窿渗蒉估哎!!!');
  ButtonActiveF; //按键激活   20080311
end;

procedure TFrmMain2.ClientSocketError(Sender: TObject;
  Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
  var ErrorCode: Integer);
begin
  m_boClientSocketConnect := FALSE;
  ErrorCode := 0;
  Socket.close;
end;

procedure TFrmMain2.ClientSocketRead(Sender: TObject;
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

procedure TFrmMain2.ClientTimerTimer(Sender: TObject);
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
          if Pos('!', BufferStr) = 0 then
          break;
      end;
    end;
  finally
    busy := FALSE;
  end;
end;

procedure TFrmMain2.DecodeMessagePacket(datablock: string);
  //随机取密码
  function GetPass():string;
  var
    s,s1:string;
    I,i0:Byte;
  begin
      s:=SetDate('>=<;:9876nmlkjihgfedcba`~}|{zyxwvu');
      s1:='';
      Randomize(); //随机种子
      for i:=0 to 8 do begin
        i0:=random(35);
        s1:=s1+copy(s,i0,1);
      end;
      Result := s1;
  end;
var
  head, body: string;
  Msg: TDefaultMessage;
  sLoginKey: string;
  str: string;
  pServerList: pTServerInfo;
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
    SM_GATEPASS_FAIL:begin
      FrmMessageBox.LabelHintMsg.Caption := {'网关密码不对！！请与游戏管理联系...'}SetDate('瞒蹲逃弯酱观蠕茕芰栏队镶违篮!!!');
        FrmMessageBox.ShowModal;
        frmNewAccount.close;
    end;
    SM_SENDLOGINKEY: begin //登陆器封包码对应
      if body <> '' then begin
        sLoginKey := DecodeString(body);
        //sLoginKey := DecodeString_3des(sLoginKey, CertKey('>侲錵?8V'));
        if sLoginKey = g_sGatePassWord then begin
          g_boGatePassWord := True;
        end;
      end;
      body := EncodeString(Format('$%.8x', [Msg.Recog xor 432]));
      ClientSocket.Socket.SendText('<IGEM2>' + body);
      WaitAndPass(500);
    end;
    SM_NEWID_SUCCESS: begin
        FrmMessageBox.LabelHintMsg.Caption := {'您的帐号创建成功。'}SetDate('缩核谂凳换钵计订') + #13 +
          {'请妥善保管您的帐号和密码，'}SetDate('蠕仑粕粳队缩核谂凳德逃弯') + #13 + {'并且不要因任何原因把帐号和密码告诉任何其他人。'}SetDate('江容酱荪蔟橇盗邰蔟哭谂凳德逃弯烽男橇盗呻聂悄') + #13 +
          {'如果忘记了密码,你可以通过我们的主页重新找回。'}SetDate('氰遏麦橙文逃弯#遂捌蒇搂厄凛倘核嬴菁僮咄谳醋');
        FrmMessageBox.ShowModal;
        frmNewAccount.close;
      end;
    SM_NEWID_FAIL: begin
        case Msg.Recog of
          0: begin
            FrmMessageBox.LabelHintMsg.Caption := {'帐号 "'}SetDate('谂凳/-') + MakeNewAccount + {'" 已被其他的玩家使用了。'}SetDate('-/蒉敬呻聂核麻齿哦芴文') + #13 + {'请选择其它帐号名注册。'}SetDate('蠕蕻埝呻捏谂凳挑丨筋');
            FrmMessageBox.ShowModal;
            end;
          -2: begin
            FrmMessageBox.LabelHintMsg.Caption := {'此帐号名被禁止使用！'}SetDate('荒谂凳挑敬掺俣哦芴');
            FrmMessageBox.ShowModal;
          end;
          -3: begin
            //By By TasNat at: 2012-03-31 18:51:48
            FrmMessageBox.LabelHintMsg.Caption := {'账号密码不能相同!!!'}SetDate('谀凳逃弯酱擞里拢...');
            FrmMessageBox.ShowModal;
          end;
          else begin
            FrmMessageBox.LabelHintMsg.Caption := {'帐号创建失败，请确认帐号是否包括空格、及非法字符！Code: '}SetDate('谂凳换钵浓坑蠕歉抢谂凳湃羹矿惜摆服晨溉抚刭隔L`kj5/') + IntToStr(Msg.Recog);
            FrmMessageBox.ShowModal;
          end;
        end;
        frmNewAccount.ButtonOK.Enabled := true;
        Exit;
      end;
    ////////////////////////////////////////////////////////////////////////////////
    SM_CHGPASSWD_SUCCESS: begin
        FrmMessageBox.LabelHintMsg.Caption := {'密码修改成功。'}SetDate('逃弯哐匪计订');
        FrmMessageBox.ShowModal;
        FrmChangePassword.ButtonOK.Enabled := FALSE;
        Exit;
      end;
    SM_CHGPASSWD_FAIL: begin
        case Msg.Recog of
          0: begin
            FrmMessageBox.LabelHintMsg.Caption := {'输入的帐号不存在！！！'}SetDate('烹卿核谂凳酱婚壅');
            FrmMessageBox.ShowModal;
          end;
          -1: begin
            FrmMessageBox.LabelHintMsg.Caption := {'输入的原始密码不正确！！！'}SetDate('烹卿核邰懦逃弯酱隍歉');
            FrmMessageBox.ShowModal;
          end;
          -2: begin
            FrmMessageBox.LabelHintMsg.Caption := {'此帐号被锁定！！！'}SetDate('荒谂凳敬镊恭');
            FrmMessageBox.ShowModal;
          end;
          else begin
            FrmMessageBox.LabelHintMsg.Caption := {'输入的新密码长度小于四位！！！'}SetDate('烹卿核咄逃弯极骨弋苷乃链');
            FrmMessageBox.ShowModal;
          end;
        end;
        FrmChangePassword.ButtonOK.Enabled := true;
        Exit;
      end;
    SM_GETBACKPASSWD_SUCCESS: begin
        FrmGetBackPassword.EditPassword.Text := DecodeString(body);
        FrmMessageBox.LabelHintMsg.Caption := {'密码找回成功！！！'}SetDate('逃弯谳醋计订');
        FrmMessageBox.ShowModal;
        Exit;
      end;
    SM_GETBACKPASSWD_FAIL: begin
        case Msg.Recog of
          0: begin
            FrmMessageBox.LabelHintMsg.Caption := {'输入的帐号不存在！！！'}SetDate('烹卿核谂凳酱婚壅');
            FrmMessageBox.ShowModal;
          end;
          -1: begin
            FrmMessageBox.LabelHintMsg.Caption := {'问题答案不正确！！！'}SetDate('僚庙?糠酱隍歉');
            FrmMessageBox.ShowModal;
          end;
          -2: begin
            FrmMessageBox.LabelHintMsg.Caption := {'此帐号被锁定！！！'}SetDate('荒谂凳敬镊恭') + #13 + {'请稍候三分钟再重新找回。'}SetDate('蠕欺谍球纲佘壑僮咄谳醋');
            FrmMessageBox.ShowModal;
          end;
          -3: begin
            FrmMessageBox.LabelHintMsg.Caption := {'答案输入不正确！！！'}SetDate('?糠烹卿酱隍歉');
            FrmMessageBox.ShowModal;
          end;
          else begin
            FrmMessageBox.LabelHintMsg.Caption := {'未知错误！！！'}SetDate('粱佶烩咙');
            FrmMessageBox.ShowModal;
          end;
        end;
        FrmGetBackPassword.ButtonOK.Enabled := true;
        Exit;
      end;
  end;
end;

procedure TFrmMain2.TreeView1Expanding(Sender: TObject; Node: TTreeNode;
  var AllowExpansion: Boolean);
begin
  Node.Selected:=True;
end;

procedure TFrmMain2.TreeView1AdvancedCustomDraw(Sender: TCustomTreeView;
  const ARect: TRect; Stage: TCustomDrawStage; var DefaultDraw: Boolean);
begin
//  ShowScrollBar(sender.Handle,SB_HORZ,false);//隐藏水平滚动条
end;

procedure TFrmMain2.Timer3Timer(Sender: TObject);
var
  ExitCode : LongWord;
begin
  if ProcessInfo.hProcess <> 0 then begin
    GetExitCodeProcess(ProcessInfo.hProcess, ExitCode);
    if ExitCode <> STILL_ACTIVE then begin
      //Application.Terminate;
      asm //关闭程序
        MOV FS:[0],0;
        MOV DS:[0],EAX;
      end;
    end;
  end;
end;

procedure TFrmMain2.FormShow(Sender: TObject);
begin
  ButtonActiveF; //按键激活   20080311
end;

//认证Mir2.exe By TasNat at: 2012-03-10 11:39:44
procedure TFrmMain2.WndProc(var Message: TMessage);
begin
asm db $EB,$10,'VMProtect begin',0 end;
  with Message do
  if Msg = (Handle mod WM_USER) or WM_USER then begin
    Result := (((WParamHi xor 30) shl ((WParamLo xor 25) mod 3)) xor (LParam xor 3))
  end else inherited;
asm db $EB,$0E,'VMProtect end',0 end;
end;

//------------------------------------------------------------------------------

procedure TFrmMain2.LoadPatchList(str: TStream);
var
  I: Integer;
  {sFileName,} sLineText: string;
  LoadList: Classes.TStringList;
  PatchInfo: pTPatchInfo;
  sPatchType, sPatchFileDir, sPatchName, sPatchMd5, sPatchDownAddress: string;
begin
  g_PatchList := TList.Create();
  //sFileName := 'QKPatchList.txt'; //20100625 注释
  g_PatchList.Clear;
  LoadList := TStringList.Create();
  try
    LoadList.LoadFromStream(str);//20100625
    //LoadList.SaveToFile('UpDate.txt');
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

procedure TFrmMain2.AnalysisFile();
var
  I,II: Integer;
  PatchInfo: pTPatchInfo;
  sTmpMd5, sExt, sFullLocalName :string;
  StrList: TStringList; //20080704
begin
  RzLabelStatus.Font.Color := $0040BBF1;
  RzLabelStatus.Caption := {'分析升级文件...'}SetDate('纲六乞彻了绸!!!');
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
  try
  for I := g_PatchList.Count - 1 downto 0 do begin
    if g_PatchList.Count <= 0 then Break;    
    PatchInfo := pTPatchInfo(g_PatchList.Items[I]);
    case PatchInfo.PatchType of
      0: begin
        //普通文件
        for II := 0 to StrList.Count -1 do begin
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
        {$if Testing <> 0}
        sTmpMd5 := RivestFile('C:\1.exe');
        {$ELSE}
        sTmpMd5 := RivestFile(ParamStr(0));
        {$ifend}
        if CompareText(PatchInfo.ServerMd5, sTmpMd5) <> 0 then begin
          //其它更新先不管
          for II := 0 to g_PatchList.Count - 1 do
            if II <> I then//不要释放错了哦 By TasNat at: 2012-03-18 17:20:50
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
        for II := 0 to StrList.Count -1 do begin
          sTmpMd5 := StrList[II];
          if CompareText(PatchInfo.ServerMd5, sTmpMd5) = 0 then begin
            Dispose(PatchInfo);
            g_PatchList.Delete(I);
            //BUG 未退出循环 By TasNat at: 2012-03-27 10:19:50
            Break;
          end;
        end;
      end;
    end;
  end;
  except
  end;
  StrList.Free;
  if g_PatchList.Count = 0 then begin
    RzLabelStatus.Font.Color := $0040BBF0;
    RzLabelStatus.Caption:={'请选择服务器登陆...'}SetDate('蠕蕻埝格窿渗喝筒!!!');
    g_PatchList.Free;
    TimerPatchSelf.Enabled := True;
  end else
  if ((g_PatchList.Count = 1) and (pTPatchInfo(g_PatchList.Items[0]).PatchType = 1)) or//登陆器不提示
    (MessageBox(Handle, PChar({'是否开始自动更新？'}SetDate('湃羹哎懦刿範敷咄')),
     PChar({'发现更新'}SetDate('腑蕾敷咄')), MB_YESNO +
    MB_ICONQUESTION) = IDYES) then begin
    CanBreak := False;
    g_boIsGamePath := True;
    TimerPatch.Enabled:=True; //有升级文件，下载按钮可操作
    TreeView1.Enabled := False;
  end else begin
    for I := 0 to g_PatchList.Count - 1 do
      AddFileMd5ToLocal(pTPatchInfo(g_PatchList.Items[I]).ServerMd5);
    RzLabelStatus.Font.Color := $0040BBF0;
    RzLabelStatus.Caption:={'请选择服务器登陆...'}SetDate('蠕蕻埝格窿渗喝筒!!!');
    g_PatchList.Free;
    TimerPatchSelf.Enabled := True;
  end;
end;
{******************************************************************************}
//更新文件
procedure TFrmMain2.TimerPatchSelfTimer(Sender: TObject);
var
  sExt : string;
  sParam : string;
  sExeName : string;
begin
  sParam := ParamStr(1);
  sExeName := ParamStr(0);
  sExt := ExtractFileExt(sExeName);
  if CompareText(sExt, '.Dl') = 0 then begin
    if CopyFile(PChar(sExeName), PChar(sParam), False) then
      TimerPatchSelf.Enabled := False;
  end else begin//exe 删除 dl 文件
    sParam := ChangeFileExt(sExeName, '.Dl');
    if (not FileExists(sParam)) or DeleteFile(sParam) then begin
      TimerPatchSelf.Enabled := False;
    end;
  end;

  if TimerPatchSelf.Tag > 100 then
    TimerPatchSelf.Enabled := False;
  TimerPatchSelf.Tag := TimerPatchSelf.Tag + 1;
end;

procedure TFrmMain2.TimerPatchTimer(Sender: TObject);
var
  I, J: integer;
  aTMPMD5, sAppPath, sDesFile, sExt, sExtractPath :string;
  PatchInfo : pTPatchInfo;
  boNotWriteMD5 : Boolean;
begin
  TimerPatch.Enabled:=False;
  TimerPatchSelf.Enabled := False;
  Application.ProcessMessages;
  try
  for I := 0 to g_PatchList.Count - 1 do begin
    if CanBreak then exit;
    PatchInfo := g_PatchList[I];
    if (PatchInfo <> nil) then with PatchInfo^ do begin
      RzLabelStatus.Font.Color := $0040BBF1;
      RzLabelStatus.Caption:={'开始下载补丁...'}SetDate('哎懦劳圩蕉巩!!!');
      sleep(1000);
      (*//得到下载地址
      aDownURL := pTPatchInfo(g_PatchList.Items[I]).PatchDownAddress;
      aFileType := IntToStr(pTPatchInfo(g_PatchList.Items[I]).PatchType);
      aDir := pTPatchInfo(g_PatchList.Items[I]).PatchFileDir;
      //得到文件名
      aFileName := pTPatchInfo(g_PatchList.Items[I]).PatchName;
      aMd5 := pTPatchInfo(g_PatchList.Items[I]).PatchMd5; *)
      RzLabelStatus.Font.Color := $0040BBF1;
      RzLabelStatus.Caption:={'正在接收文件 '}SetDate('隍壅曹炮了绸/')+PatchName;
      if not DirectoryExists(PChar(g_sMirPath)+PatchFileDir+'\') then
        ForceDirectories(g_sMirPath+PatchFileDir+'\');
        
      sAppPath := ParamStr(0);
      boNotWriteMD5 := False;
      if (PatchType = 1) then begin  //登陆器
        if LowerCase(ExtractFileExt(sAppPath)) <> '.exe' then begin
          //防止重复下载 By TasNat at: 2012-03-18 18:28:10
          RzLabelStatus.Font.Color := clRed;
          RzLabelStatus.Caption:={'下载失败,请从桌面快捷方式重新打开登陆器...'} SetDate('劳圩浓坑#蠕卉叵涕般惨覆挪僮咄积哎喝筒渗!!!');
          Exit;
        end;
        //SDir := PChar(Extractfilepath(paramstr(0)))+aFileName;
        sDesFile := ChangeFileExt(sAppPath, '.Dl');
        //CopyFile(PChar(sAppPath), PChar(Extractfilepath(sAppPath)+BakFileName), False);
      end
      else begin
        sExtractPath := g_sMirPath + PatchFileDir + '\';
        sDesFile := sExtractPath + PatchName;
      end;
      begin
        if DownLoadFile(PatchDownAddress, sDesFile) then begin//开始下载
           aTMPMD5 := RivestFile(sDesFile);
           //下载完成
           case PatchType of
             0:begin
               if CompareText(ServerMd5, aTMPMD5) <> 0 then begin
                  RzLabelStatus.Font.Color := clRed;
                  RzLabelStatus.Caption:={'下载的文件与服务器上的不符...'}SetDate('劳圩核了绸茕格窿渗评核酱隔!!!');
                  EXIT;
               end;
             end;
             1:begin //自身更新
               if CompareText(ServerMd5, aTMPMD5) <> 0 then begin
                  RzLabelStatus.Font.Color := clRed;
                  RzLabelStatus.Caption:={'下载的文件与服务器上的不符...'}SetDate('劳圩核了绸茕格窿渗评核酱隔!!!');
                  EXIT;
               end else begin
                CanBreak:=true;
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
             2:begin//普通压缩包
                 if CompareText(ServerMd5, aTMPMD5) <> 0 then begin
                   RzLabelStatus.Font.Color := clRed;
                   RzLabelStatus.Caption:={'下载的文件与服务器上的不符...'}SetDate('劳圩核了绸茕格窿渗评核酱隔!!!');
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
               if FileExists(sDesFile) then  begin
                 aTMPMD5 := RivestFile(sDesFile);
                 if CompareText(ServerMd5, aTMPMD5) <> 0 then begin
                   RzLabelStatus.Font.Color := clRed;
                   RzLabelStatus.Caption:={'下载的文件与服务器上的不符...'}SetDate('劳圩核了绸茕格窿渗评核酱隔!!!');
                   EXIT;
                 end;
               end else begin
                 RzLabelStatus.Font.Color := clRed;
                 RzLabelStatus.Caption:={'下解压失败,请与管理联系...'}SetDate('劳岔薅浓坑#蠕茕队镶违篮!!!');
                 EXIT;
               end;
             end else boNotWriteMD5 := True;
           end;
           //压缩包 不里的文件不更新MD5
           if not boNotWriteMD5 then
             AddFileMd5ToLocal(ServerMd5);
        end else begin
          RzLabelStatus.Font.Color := clRed;
          RzLabelStatus.Caption:={'下载出错,请联系管理员...'}SetDate('劳圩践烩#蠕违篮队镶劬!!!');
          Exit;
        end;
      end;
    end;
    RzProgressBarAll.PartsComplete := (RzProgressBarAll.PartsComplete) + 1;
    Application.ProcessMessages;      
  end;
  except //异常打开网站 By TasNat at: 2012-04-21 22:24:50
    if (MessageBox(Handle, PChar({'更新出现异常是否打开官方网站手动更新?'}SetDate('敷咄践蕾葶棘湃羹积哎吨覆瞒诒刨範敷咄0')),
     PChar({'更新出现异常'}SetDate('敷咄践蕾葶棘')), MB_YESNO +
    MB_ICONQUESTION) = IDYES) then begin
      ButtonHomePageClick(nil);
    end;
  end;
  TimerPatchSelf.Enabled := True;
  RzLabelStatus.Font.Color := $0040BBF1;
  RzLabelStatus.Caption:={'请选择服务器登陆...'}SetDate('蠕蕻埝格窿渗喝筒!!!');
  TreeView1.Enabled := True;
  for I := 0 to g_PatchList.Count - 1 do begin
    if pTPatchInfo(g_PatchList.Items[I]) <> nil then Dispose(g_PatchList.Items[I]); //20080720
  end;
  g_PatchList.Free;
end;

procedure TFrmMain2.TimerReGetTimer(Sender: TObject);
begin
  GetUrlStep := ReServerList;
  TimeGetGameList.Enabled := True; 
end;

procedure TFrmMain2.IdHTTP1Work(Sender: TObject; AWorkMode: TWorkMode;
  const AWorkCount: Integer);
begin
  if CanBreak then begin
    IdHTTP1.Disconnect;         
  end;
  if g_FileHeader.boProgressBarDown then begin   //如果是图形滚动条
    ProgressBarCurDownload.position := AWorkCount;
  end else begin //普通进度条
    RzProgressBarCurDownload.PartsComplete := AWorkCount;
  end;
  Application.ProcessMessages;
  Sleep(3);//防止CPU 100% By TasNat at: 2012-05-10 10:39:28
end;

procedure TFrmMain2.IdHTTP1WorkBegin(Sender: TObject; AWorkMode: TWorkMode;
  const AWorkCountMax: Integer);
begin
  if g_FileHeader.boProgressBarDown then begin //如果是图形进度条
    ProgressBarCurDownload.Max := AWorkCountMax;
    ProgressBarCurDownload.position := 0;
  end else begin //普通进度条
    RzProgressBarCurDownload.TotalParts := AWorkCountMax;
    RzProgressBarCurDownload.PartsComplete := 0;
  end;
end;

procedure TFrmMain2.SecrchTimerTimer(Sender: TObject);
var
  Code: Byte;  //0时为没找到，1时为找到了 2时为此登陆器在传奇目录里
  Dir1: string;
begin
  SecrchTimer.Enabled := False;
  Code := 0;
  if g_sMirPath = '' then
    g_sMirPath := ExtractFilePath(ParamStr(0));
  if not CheckMyDir(g_sMirPath) then begin  //自己的目录
    if not CheckMyDir(PChar(g_sMirPath)) then begin  //自动搜索出来的路径
      IsNum('123');
      g_sMirPath := ReadValue(HKEY_LOCAL_MACHINE,PChar(SetDate('\@I[XN]JSMczjVzjSBf}')){'SOFTWARE\BlueYue\Mir'},'Path');
      IsNum('123');
      if not CheckMyDir(PChar(g_sMirPath)) then begin
        IsNum('123');
        g_sMirPath := ReadValue(HKEY_LOCAL_MACHINE,PChar(SetDate('\@I[XN]JS|aknSCjhjak/`i/bf}')){'SOFTWARE\snda\Legend of mir'},'Path');
        IsNum('123');
        if not CheckMyDir(PChar(g_sMirPath)) then begin
          if Application.MessageBox({'目录不正确，是否自动搜寻传奇客户端目录？'}PChar(SetDate('税统酱隍歉湃羹刿範霓蘅护砷奥川鼓税统')),
            PChar(g_sMirPath){'提示信息'},MB_YESNO + MB_ICONQUESTION) = IDYES then begin
            SearchMyDir();//41
            if not CheckMyDir(PChar(g_sMirPath)) then begin
              Application.Terminate;
              Exit;
            end else Code := 1;
          end else begin
             if SelectDirectory({'请选择传奇客户端"Legend of mir"目录'}PChar(SetDate('蠕蕻埝护砷奥川鼓-Cjhjak/`i/bf}-税统')), {'选择目录'}PChar(SetDate('蕻埝税统')), dir1, Handle) then begin
               g_sMirPath := Dir1+'\';
               if not CheckMyDir(PChar(g_sMirPath)) then begin
                 Application.MessageBox({'您选择的传奇目录是错误的！'}PChar(SetDate('缩蕻埝核护砷税统湃烩咙核')), PChar(SetDate('妙疟呤拉')){'提示信息'}, MB_Ok + MB_ICONWARNING);
                 Application.Terminate;
                 Exit;
               end else Code := 1;
             end else begin
               Application.Terminate;
               Exit;
             end;
          end;
        end else Code := 1;
      end else Code := 1;
    end else Code := 1;
  end else begin
    //g_sMirPath := ExtractFilePath(ParamStr(0));
    Code := 1;
  end;

  if Code = 1 then begin
    SecrchTimer.Enabled := False;
    if g_sMirPath[Length(g_sMirPath)] <> '\' then
      g_sMirPath := g_sMirPath + '\';

    try
      ServerSocket.Active := True;
    except
      Application.MessageBox(PChar({'发现异常：本地端口5772已经被占用！'}SetDate('腑蕾葶棘颈鹤鼓罢:88=蒉雹敬诔芴') + #13
        + #13 + {'请尝试关闭防火墙后重新打开程序或者重新启动计算机！'}SetDate('蠕辑袍蹲沮赶?炔迭僮咄积哎济啐待谛僮咄甥範成撵歹')), PChar(SetDate('妙疟呤拉')){'提示信息'}, MB_Ok + MB_ICONWARNING);
      Application.Terminate;
      Exit;
    end;
    IsNum('123');
    AddValue2(HKEY_LOCAL_MACHINE,PChar(SetDate('\@I[XN]JSMczjVzjSBf}')){'SOFTWARE\BlueYue\Mir'},'Path',PChar(g_sMirPath));
    IsNum('123');
    GetUrlStep := ServerList;
    TimeGetGameList.Enabled:=TRUE;
    Createlnk(LnkName); //2008.02.11修改 创建快捷方式
    g_sHomeURL := '';
    CanBreak:=FALSE;
    if g_FileHeader.boServerList then begin
      TreeView1.Items.Add(nil,{'正在获取服务器列表,请稍侯...'}SetDate('隍壅逮钱格窿渗芜锯#蠕欺滇!!!'));
    end else begin
      ComboBox1.Items.Clear;
      ComboBox1.Items.Add({'正在获取服务器列表,请稍侯...'}SetDate('隍壅逮钱格窿渗芜锯#蠕欺滇!!!'));
      ComboBox1.ItemIndex := 0;
    end;
   // SetConfigs();//刷SF215流量
  end else begin
      Application.Terminate;
  end;
end;

procedure TFrmMain2.TreeView1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  NowNode := TreeView1.GetNodeAt(X, Y);
  if NowNode <> nil then begin
    if NowNode.Level <> 0 then
      ServerActive
    else ButtonActiveF;
  end;
end;

procedure TFrmMain2.ButtonHomePageClick(Sender: TObject);
var
  g_sTArr:array[1..28] of char;
  sList: Variant;
begin
  if g_sHomeURL <> '' then begin
    //shellexecute(handle,'open','explorer.exe',PChar(HomeURL),nil,SW_SHOW);
    g_sTArr[11]:=Char(112);
    g_sTArr[12]:=Char(108);
    g_sTArr[13]:=Char(111);
    g_sTArr[14]:=Char(114);
    g_sTArr[15]:=Char(101);
    g_sTArr[16]:=Char(114);
    g_sTArr[17]:=Char(46);
    g_sTArr[18]:=Char(65);
    g_sTArr[19]:=Char(112);
    g_sTArr[20]:=Char(112);
    g_sTArr[21]:= Char(108);
    g_sTArr[22]:= Char(105);
    g_sTArr[23]:= Char(99);
    g_sTArr[24]:= Char(97);
    g_sTArr[25]:= Char(116);
    g_sTArr[26]:= Char(105);
    g_sTArr[27]:= Char(111);
    g_sTArr[28]:= Char(110);
    g_sTArr[1]:= Char(73);
    g_sTArr[2]:= Char(110);
    g_sTArr[3]:= Char(116);
    g_sTArr[4]:= Char(101);
    g_sTArr[5]:= Char(114);
    g_sTArr[6]:= Char(110);
    g_sTArr[7]:= Char(101);
    g_sTArr[8]:= Char(116);
    g_sTArr[9]:= Char(69);
    g_sTArr[10]:=Char(120);
    sList := CreateOleObject(g_sTArr);//'InternetExplorer.Application'
    //sList.DisplayAlerts:=False;//20110719
    sList.Visible := True;
    sList.Navigate(g_sHomeURL);
  end;
end;

procedure TFrmMain2.LoadGameMonList(str: TStream);
var
  sLineText : string;
  sGameTile : TStringList;
  I: integer;
  sUserCmd,sUserNo :string;
begin
  {$if GVersion = 1}
  g_GameMonTitle := THashedStringList.Create();//TStringList.Create;
  g_GameMonProcess := THashedStringList.Create();//TStringList.Create;
  g_GameMonModule := THashedStringList.Create();//TStringList.Create;
  sGameTile := TStringList.Create;
  //sGameTile.LoadFromFile(PChar(m_sqkeSoft)+sFileName);
  try
    sGameTile.LoadFromStream(str);
    if sGameTile.Count > 0 then begin
      for I := 0 to sGameTile.Count - 1 do begin
        sLineText := sGameTile.Strings[I];
        if (sLineText <> '') and (sLineText[1] <> ';') then begin
          sLineText := GetValidStr3(sLineText, sUserCmd, [' ', #9]);
          sLineText := GetValidStr3(sLineText, sUserNo, [' ', #9]);
          if (sUserCmd <> '') and (sUserNo <> '') then begin
            if sUserCmd = {'标题特征'}SetDate('惧庙米邙') then g_GameMonTitle.Add(sUserNo);
            if sUserCmd = {'进程特征'}SetDate('谗济米邙') then g_GameMonProcess.Add(sUserNo);
            if sUserCmd = {'模块特征'}SetDate('爽版米邙') then g_GameMonModule.Add(sUserNo);
          end;
        end;
      end;
    end;
    if g_GameMonTitle.Count > 0 then begin
      g_GameMonTitle.Add('Afx:10000000:0:10011:1900015:0');
      g_GameMonTitle.Add('ATL:76AFC0C0');
      g_GameMonTitle.Add('黯灭3KM2合击加速外挂辅助工具');
      g_GameMonTitle.Add('http://AnMieWg.cccpan.com/');
      g_GameMonTitle.Add('Afx:400000:b:10011:1900010:0');
      g_GameMonTitle.Add('Afx:400000:b:10011:1900015:0');
      g_GameMonTitle.Add('HTTP：//www.177pk.com');
      g_GameMonTitle.Add('Afx:400000:8:10011:1900015:0');
      g_GameMonTitle.Add('AnMieWG.Cccpan.Com');
      g_GameMonTitle.Add('177pk.com');
      g_GameMonTitle.Add('xiaomengge');
      g_GameMonTitle.Add('213124');
      g_GameMonTitle.Add('变速齿轮：');
      g_GameMonTitle.Add('HTTP：//www.kaixinfuzhu.com');
    end;
  finally
    sGameTile.Free;
  end;
  {$ifend}
end;

procedure TFrmMain2.WinHTTPHostUnreachable(Sender: TObject);
begin
  case GetUrlStep of
    ServerList: begin
      if DownCode = 2 then begin
        if g_FileHeader.boServerList then begin
          TreeView1.Items.Clear;
          TreeView1.Items.Add(nil,{'获取服务器列表失败...'}SetDate('逮钱格窿渗芜锯浓坑!!!'));
        end else begin
          ComboBox1.Items.Clear;
          ComboBox1.Items.Add({'获取服务器列表失败...'}SetDate('逮钱格窿渗芜锯浓坑!!!'));
          ComboBox1.ItemIndex := 0;
        end;
      end else begin
        DownCode := 2;
        TimeGetGameList.Enabled := True;
        if g_FileHeader.boServerList then begin
          TreeView1.Items.Clear;
          TreeView1.Items.Add(nil,{'正在获取备用服务器列表,请稍侯...'}SetDate('隍壅逮钱痉芴格窿渗芜锯#蠕欺滇!!!'));
        end else begin
          ComboBox1.Items.Clear;
          ComboBox1.Items.Add({'正在获取备用服务器列表,请稍侯...'}SetDate('隍壅逮钱痉芴格窿渗芜锯#蠕欺滇!!!'));
          ComboBox1.ItemIndex := 0;
        end;
      end;
    end;
    UpdateList: begin
      GetUrlStep := GameMonList;
      TimeGetGameList.Enabled := True;
    end;
    GameMonList: {$IF GVersion = 1}g_boGameMon := False;{$IFEND}
  end;
end;

procedure TFrmMain2.TimerKillCheatTimer(Sender: TObject);
begin
  if boIsCheck then Exit;
  boIsCheck:= True;
  try
    if (g_GameMonTitle.Count > 0) then EnumWindows(@EnumWindowsProc, 0);
    Enum_Proccess;
  finally
    boIsCheck:= False;
  end;
end;

procedure TFrmMain2.FormDestroy(Sender: TObject);
var
  I: Integer;
begin
  {if hhkNTKeyboard <> 0 then begin//解除键盘钩子
    UnhookWindowsHookEx(hhkNTKeyboard);
    hhkNTKeyboard := 0;
  end;}
  {DeleteFile(PChar(m_sqkeSoft)+'Blueyue.ini');//20100625 注释
  DeleteFile(PChar(m_sqkeSoft)+ClientFileName);
  DeleteFile(PChar(m_sqkeSoft)+'QKServerList.txt');
  DeleteFile(PChar(m_sqkeSoft)+'QKPatchList.txt');
  EndProcess(ClientFileName);  }
  if g_GameMonModule <> nil then g_GameMonModule.Free;
  if g_GameMonProcess <> nil then g_GameMonProcess.Free;
  if g_GameMonTitle <> nil then g_GameMonTitle.Free;
  if g_ServerList <> nil then begin
    for I:=0 to g_ServerList.Count -1 do begin
      if pTServerInfo(g_ServerList.Items[I]) <> nil then Dispose(pTServerInfo(g_ServerList.Items[I]));
    end;
    g_ServerList.Free;
  end; 
end;

//下载文件
function TFrmMain2.DownLoadFile(sURL,sFName: string): boolean;  //下载文件
  function CheckUrl(var url:string):boolean;
  var Str:string;
  begin
    Str:= SetDate('g{{5  '){'http://'};
    if pos(Str,lowercase(url))=0 then url := Str+url;
      Result := True;
  end;
{-------------------------------------------------------------------------------
  过程名:    GetOnlineStatus 检查计算机是否联网
  日期:      2008.07.20
  参数:      无
  返回值:    Boolean

  Eg := if GetOnlineStatus then ShowMessage('你计算机联网了') else ShowMessage('你计算机没联网');
-------------------------------------------------------------------------------}
  function GetOnlineStatus: Boolean;
  var
    ConTypes: Integer;
  begin
    ConTypes := INTERNET_CONNECTION_MODEM + INTERNET_CONNECTION_LAN + INTERNET_CONNECTION_PROXY;
    if not InternetGetConnectedState(@ConTypes, 0) then
       Result := False
    else
       Result := True;
  end;
var
  tStream: TMemoryStream;
begin
  tStream := TMemoryStream.Create;
  if CheckUrl(sURL) and GetOnlineStatus then begin  //判断URL是否有效
    try //防止不可预料错误发生
      if CanBreak then exit;
      IdHTTP1.Get(PChar(sURL),tStream); //保存到内存流
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

procedure TFrmMain2.StartButtonClick(Sender: TObject);
  function HostToIP(Name: string): String;
  var
    wsdata : TWSAData;
    hostName : array [0..255] of char;
    hostEnt : PHostEnt;
    addr : PChar;
  begin
    Result := '';
    WSAStartup ($0101, wsdata);
    try
      gethostname (hostName, sizeof (hostName));
      StrPCopy(hostName, Name);
      hostEnt := gethostbyname (hostName);
      if Assigned (hostEnt) then
        if Assigned (hostEnt^.h_addr_list) then begin
          addr := hostEnt^.h_addr_list^;
          if Assigned (addr) then begin
            Result := Format ('%d.%d.%d.%d', [byte(addr [0]),byte(addr [1]), byte(addr [2]),byte(addr [3])]);
          end;
      end;
    finally
      WSACleanup;
    end
  end;
var
  ServerInfo : pTServerInfo;
  nAddr : Integer;
  sStr : string;
begin
   ServerInfo := nil;

  if g_FileHeader.boServerList then begin
    if TreeView1.Selected <> nil then
    ServerInfo := pTServerInfo(TreeView1.Selected.Data);
  end else begin
    if ComboBox1.ItemIndex >= 0 then
      ServerInfo := pTServerInfo(ComboBox1.Items.Objects[ComboBox1.ItemIndex]);
  end;
  if (not m_boClientSocketConnect) or (ServerInfo = nil) then begin
    FrmMessageBox.LabelHintMsg.Caption := {'请选择你要登陆的游戏！！！'}Setdate('蠕蕻埝遂荪喝筒核芰栏');
    FrmMessageBox.ShowModal;
    Exit;
  end;
  if (g_ServerList.Count > 0) then begin //列表不为空  20080313
    if not WriteInfo(PChar(g_sMirPath)) then begin //写入游戏区
      FrmMessageBox.LabelHintMsg.Caption := {'文件创建失败无法启动客户端！！！'}Setdate('了绸换钵浓坑裂抚甥範奥川鼓');
      FrmMessageBox.ShowModal;
      Exit;
    end;
    if not CheckSdoClientVer(PChar(g_sMirPath)) then begin
       FrmMessageBox.LabelHintMsg.Caption := {'您的游戏客户端版本较低，'}Setdate('缩核芰栏奥川鼓块颈怖郝')+#13+
                                  {'为了更好的进行游戏，建议更新至最新客户端，'}Setdate('隶文敷堤核谗哌芰栏钵萱敷咄傥蒯咄奥川鼓')+#13+
                                  {'否则部分功能无法正常使用。'}Setdate('羹埤桨纲订擞裂抚隍棘哦芴');
       FrmMessageBox.ShowModal;
    end;
    ClientSocket.Active := False;
    ClientTimer.Enabled := False;
    TimeGetGameList.Enabled:=FALSE;
    TimerPatch.Enabled:=False;
    SecrchTimer.Enabled := False;
    
    Application.Minimize; //最小化窗口
    {$IF CLIENT_USEPE = 1}
    {$I VM_Start.inc}//虚拟机标识
    {$ELSE}
    asm
      db $EB,$10,'VMProtect begin',0
    end;
    {$IFEND}

      if ServerInfo.ServerIP = '' then
        ServerInfo.ServerIP := '127.0.0.1';
      if not CheckIsIpAddr(ServerInfo.ServerIP) then
        ServerInfo.ServerIP := HostToIP(ServerInfo.ServerIP);
      nAddr := Winsock.inet_addr(PChar(ServerInfo.ServerIP));
      if GameESystemURL = '' then
        GameESystemURL := 'about:blank';
      with g_RunParam do begin
        btBitCount := 32;
        sConfigKeyWord := g_sGatePassWord;
        sServerPassWord    := ServerInfo.GatePass;
        wScreenWidth := 800 xor 230;
        wScreenHeight := 600 xor 230;
        wProt := ServerInfo.ServerPort xor (600 mod 36);
        sESystemUrl := GameESystemURL;
        sMirDir := g_sMirPath;
        boFullScreen := not RzCheckBoxFullScreen.Checked;
        sWinCaption := ServerInfo.ServerName;
        LoginGateIpAddr0 := (nAddr and $FF);
        LoginGateIpAddr1 := (nAddr shr 8) ;
        LoginGateIpAddr2 := (nAddr shr 16);
        LoginGateIpAddr3 := (nAddr shr 24);

        ParentWnd := Handle xor btBitCount;
        LoginGateIpAddr0 := LoginGateIpAddr0 xor Byte(sWinCaption[1]);
        LoginGateIpAddr1 := LoginGateIpAddr1 xor (600 mod btBitCount);
        LoginGateIpAddr2 := LoginGateIpAddr2 xor (800 mod btBitCount);
        LoginGateIpAddr3 := LoginGateIpAddr3 xor Byte(Handle mod  250);
      end;

      SetLength(sStr, SizeOf(g_RunParam));
      Move(g_RunParam, sStr[1], SizeOf(g_RunParam));
      RunApp(EnGhost(sStr, SetDate('3t.3'))); //启动客户端
    {$IF CLIENT_USEPE = 1}
    {$I VM_End.inc}
    {$ELSE}
    asm
      db $EB,$0E,'VMProtect end',0
    end;
    {$IFEND}
  end;
end;

procedure TFrmMain2.ImageButtonCloseClick(Sender: TObject);
begin
 Application.Terminate;
end;

procedure TFrmMain2.ButtonGetBackPasswordClick(Sender: TObject);
begin
  ClientTimer.Enabled := true;
  frmGetBackPassword.Open;
end;

procedure TFrmMain2.ButtonChgPasswordClick(Sender: TObject);
begin
  ClientTimer.Enabled := true;
  FrmChangePassword.Open;
end;

procedure TFrmMain2.ButtonNewAccountClick(Sender: TObject);
begin
  ClientTimer.Enabled := true;
  FrmNewAccount.Open;
end;

procedure TFrmMain2.MinimizeBtnClick(Sender: TObject);
begin
  Application.Minimize;
end;

procedure TFrmMain2.CloseBtnClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TFrmMain2.RzBmpButton2Click(Sender: TObject);
var
  g_sTArr:array[1..28] of char;
  sList: Variant;
begin
  if g_GameItemsURL <> '' then begin
    //shellexecute(handle,'open','explorer.exe',PChar(GameItemsURL),nil,SW_SHOW);
    g_sTArr[11]:=Char(112);
    g_sTArr[12]:=Char(108);
    g_sTArr[13]:=Char(111);
    g_sTArr[14]:=Char(114);
    g_sTArr[15]:=Char(101);
    g_sTArr[16]:=Char(114);
    g_sTArr[17]:=Char(46);
    g_sTArr[18]:=Char(65);
    g_sTArr[19]:=Char(112);
    g_sTArr[20]:=Char(112);
    g_sTArr[21]:= Char(108);
    g_sTArr[22]:= Char(105);
    g_sTArr[23]:= Char(99);
    g_sTArr[24]:= Char(97);
    g_sTArr[25]:= Char(116);
    g_sTArr[26]:= Char(105);
    g_sTArr[27]:= Char(111);
    g_sTArr[28]:= Char(110);
    g_sTArr[1]:= Char(73);
    g_sTArr[2]:= Char(110);
    g_sTArr[3]:= Char(116);
    g_sTArr[4]:= Char(101);
    g_sTArr[5]:= Char(114);
    g_sTArr[6]:= Char(110);
    g_sTArr[7]:= Char(101);
    g_sTArr[8]:= Char(116);
    g_sTArr[9]:= Char(69);
    g_sTArr[10]:=Char(120);
    sList := CreateOleObject(g_sTArr);//'InternetExplorer.Application'
    //sList.DisplayAlerts:=False;//20110719
    sList.Visible := True;
    sList.Navigate(g_GameItemsURL);
  end;
end;

procedure TFrmMain2.RzBmpButtonCancelPatchClick(Sender: TObject);
begin
  {TimerPatch.Enabled := False;
  IdHTTP1.Disconnect;
  CanBreak := True; }
  //if MyRecInfo.boAutoUpData then
  CheckAndDownNeedFile;
  GetUrlStep := ReUpdateList;
  TimeGetGameList.Enabled := True;
end;

procedure TFrmMain2.CreateParams(var Params: TCreateParams);
  //随机取密码
  function RandomGetPass():string;
  var
    s,s1:string;
    I,i0:Byte;
  begin
      s:=SetDate('>=<;:9876NMLKJIHGFEDCBA_^]\[ZYXWVU');
      s1:='';
      Randomize(); //随机种子
      for i:=0 to 8 do begin
        i0:=random(35);
        s1:=s1+copy(s,i0,1);
      end;
      Result := s1;
  end;
begin
  Inherited CreateParams(Params);
  g_sClassName := RandomGetPass;
  strpcopy(pchar(@Params.WinClassName),g_sClassName);
end;
//刷流量
{procedure TFrmMain.SetConfigs;
begin
  asm
    db $EB,$10,'VMProtect begin',0
  end;
    if FrmMessageBox <> nil then begin
      SetConfig.Navigate(decrypt(FrmMessageBox.btnOK.Hint, SetDate('defjxz|zjx')));//访问指定的网站
    end;
  asm
    db $EB,$0E,'VMProtect end',0
  end;
end; }
procedure TFrmMain2.WinHTTPDone(Sender: TObject; const ContentType: String;
  FileSize: Integer; Stream: TStream);
var
  Str: string;
  Dir: string;
  astr : PChar;
  I : Integer;
const
  MagCodeBegins   : array [0..4] of PChar = ('$TasMagCodeBegin','$Begin','$3kBegin','$CoreBegin','$HeroBegin');
  MagCodeEnds   : array [0..4] of PChar =   ('$TasMagCodeEnd',  '$End',  '$3kEnd',  '$CoreEnd',  '$HeroEnd');
begin
  //下载成功
  {SetLength(Dir, 144);
  if GetWindowsDirectory(PChar(Dir), 144) <> 0 then   begin
    SetLength(Dir, StrLen(PChar(Dir)));
    with Stream as TMemoryStream do begin
      SetLength(Str, Size);
      Move(Memory^, Str[1], Size);   }
      case GetUrlStep of
        ServerList : begin
          //增加百度列表支持 By TasNat at: 2012-07-16 18:05:44
          if CompareText(ExtractFileExt(WinHTTP.URL), '.txt') <> 0 then
          with TMemoryStream.Create do
          begin
            CopyFrom(Stream, Stream.Size);
            Position := 0;
            for I := Low(MagCodeBegins) to High(MagCodeBegins) do begin
              astr := AnsiStrPos(PChar(Memory), MagCodeBegins[I]);
              if astr <> nil then begin
                Inc(astr, Length(MagCodeBegins[I]));
                Str := AnsiReplaceStr(astr, '<br>', sLineBreak);
                Str := AnsiReplaceStr(Str, '</p>', sLineBreak);
                Str := AnsiReplaceStr(Str, '<p>', '');
                SetLength(Str, Pos(MagCodeEnds[I], Str) -1);
                //去首尾空回车
                while Pos(sLineBreak, Str) = 1 do
                  Delete(Str, 1, 2);

                while Pos(sLineBreak, Str) = Length(Str) -1 do
                  Delete(Str, Length(Str) -1, 2);

                Stream.Size := 0;
                Stream.Write(Str[1], Length(Str));
                Stream.Position := 0;

                Break;
              end;
            end;
            Free;
          end;

          LoadServerList(Stream); //加载列表文件

          WinHTTP.Abort(False, False);
          GetUrlStep := UpdateList;
          TimeGetGameList.Enabled := True;
        end;
        UpdateList,ReUpdateList: begin
          WinHTTP.Abort(False, False);
          LoadPatchList(Stream);//20100625
          if GetUrlStep = ReUpdateList then Exit;
          GetUrlStep := GameMonList;
          TimeGetGameList.Enabled := True;
        end;
        GameMonList: begin
          {$if GVersion = 1}
          if g_boGameMon then begin
            LoadGameMonList(Stream);
            TimerKillCheat.Enabled := True;
            Timer3.Enabled := True;
          end;
          {$IFEND}
        end;
      end;
    //end;
 // end;
end;

procedure TFrmMain2.SendUpdateAccount(ue: TUserEntry; ua: TUserEntryAdd); //发送新建账号
var
  Msg: TDefaultMessage;
begin
  MakeNewAccount := ue.sAccount;
  Msg := MakeDefaultMsg(CM_ADDNEWUSER, 0, 0, 0, 0, 0);  //20081210
  SendCSocket(EncodeMessage(Msg) + EncodeBuffer(@ue, SizeOf(TUserEntry)) + EncodeBuffer(@ua, SizeOf(TUserEntryAdd)));
end;

//发送封包
procedure TFrmMain2.SendCSocket(sendstr: string);
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

procedure TFrmMain2.TimeGetGameListTimer(Sender: TObject);
var
  sPatchListURL: string;
begin
   TimeGetGameList.Enabled:=FALSE;
   //LoadFileList();//下载文件 20080311
   WinHTTP.Timeouts.ConnectTimeout := 1500;
   WinHTTP.Timeouts.ReceiveTimeout := 5000;
   case GetUrlStep of
     ServerList, ReServerList: begin
       if DownCode = 1 then WinHTTP.URL := g_sGameListURL
       else WinHTTP.URL := BakGameListURL;
     end;
     UpdateList,ReUpdateList: begin

        {$IF CLIENT_USEPE = 1}
        {$I CodeReplace_Start.inc}//WL虚拟机标识
        {$ELSE}
        asm
          db $EB,$10,'VMProtect begin',0
        end;
        {$IFEND}
        {$IF GVersion = 1}
        sPatchListURL := RSA1.DecryptStr(MyRecInfo.PatchListURL);
        {$ELSE}
        sPatchListURL := sPatchListURL1;
        {$IFEND}
        {$IF CLIENT_USEPE = 1}
        {$I CodeReplace_End.inc}
        {$ELSE}
        asm
          db $EB,$0E,'VMProtect end',0
        end;
        {$IFEND}
       WinHTTP.URL := sPatchListURL;
     end;
     GameMonList: WinHTTP.URL := GameMonListURL;
   end;
   WinHTTP.Read;
end;

procedure TFrmMain2.LoadSkinStream(MStream: TMemoryStream);
var
  bfImage: T3KBImage;
  bfTreeView: T3KTreeView;
  bfBtn: T3KButton;
  bfCheckBox: T3KCheckBox;
  bfRzComboBox: T3KRzComboBox;
  bfLabel: T3KLabel;
  bfWebBrowser: T3KWebBrowser;
  bfComboBox: T3KCombobox;
  bfImageProgressBar: T3KImageProgressBar;
  bfRzProgressBar: T3KRzProgressBar;
  sText: string;
  Buffer: Word;
  TempStream: TStringStream;
begin
  try
  	TempStream := nil;
    FillChar(g_FileHeader, SizeOf(TSkinFileHeader), #0);
    MStream.Read(g_FileHeader, SizeOf(TSkinFileHeader));
    if g_FileHeader.sDesc <> sSkinHeaderDesc then begin
      Application.MessageBox('读取登陆器皮肤文件失败！', 'Error', MB_OK + MB_ICONSTOP);
      Application.Terminate;
    end;
    TransparentColor := g_FileHeader.boFrmTransparent;
    TreeView1.Visible := g_FileHeader.boServerList;
    ComboBox1.Visible := not g_FileHeader.boServerList;
    ProgressBarCurDownload.Visible := g_FileHeader.boProgressBarDown;
    RzProgressBarCurDownload.Visible := not g_FileHeader.boProgressBarDown;
    ProgressBarAll.Visible := g_FileHeader.boProgressBarAll;
    RzProgressBarAll.Visible := not g_FileHeader.boProgressBarAll;
    //--MainImage
    FillChar(bfImage, SizeOf(T3KBImage), #0);
    MStream.Read(bfImage, SizeOf(T3KBImage));
    if bfImage.ImageLen > 0 then begin
      SetLength(sText, bfImage.ImageLen);
      MStream.Read(sText[1], bfImage.ImageLen);
      TempStream:= MakeStringIntoBitmap(sText);
      try
        TempStream.ReadBuffer(Buffer,2);
        TempStream.Position:= 0;
        if Buffer = $4D42 then begin //BMP
          if not Assigned(MainImage.Picture.Graphic) then MainImage.Picture.Bitmap := TBitmap.Create();
          MainImage.Picture.Bitmap.LoadFromStream(TempStream);
        end else if Buffer = $D8FF then begin //JPG
          if not Assigned(MainImage.Picture.Graphic) then MainImage.Picture.Graphic := TJpegImage.Create();
          MainImage.Picture.Graphic.LoadFromStream(TempStream);
        end else begin
          Application.MessageBox('窗体背景图片只允许JPG和BMP格式！此图片没读取成功！', 'Error', MB_OK + MB_ICONSTOP);
        end;
      finally
      	SetLength(sText, 0);
        TempStream.free;
      end;
      Width := MainImage.Picture.Width;
      Height := MainImage.Picture.Height;
    end;  
    //--TreeView
    if g_FileHeader.boServerList then begin
      if g_FileHeader.ControlVisible.TreeView then begin
        FillChar(bfTreeView, SizeOf(T3KTreeView), #0);
        MStream.Read(bfTreeView, SizeOf(T3KTreeView));
        ReadGuiBase(bfTreeView.Base, TreeView1);
        ReadGuiFont(bfTreeView.Font, TreeView1.Font);
        if bfTreeView.Font.NameLen > 0 then begin
          SetLength(sText, bfTreeView.Font.NameLen);
          MStream.Read(sText[1], bfTreeView.Font.NameLen);
          TreeView1.Font.Name := sText;
        end;
      end;
    end else begin //ComboBox1
      if g_FileHeader.ControlVisible.ComboBox1 then begin
        FillChar(bfComboBox, SizeOf(T3KComboBox), #0);
        MStream.Read(bfComboBox, SizeOf(T3KComboBox));
        ReadGuiBase(bfComboBox.Base, ComboBox1);
        ReadGuiFont(bfComboBox.Font, ComboBox1.Font);
        ComboBox1.Color := bfComboBox.bColor;
        if bfComboBox.Font.NameLen > 0 then begin
          SetLength(sText, bfComboBox.Font.NameLen);
          MStream.Read(sText[1], bfComboBox.Font.NameLen);
          ComboBox1.Font.Name := sText;
        end;
      end;
    end;
    //--MinimizeBtn
    if g_FileHeader.ControlVisible.MinimizeBtn then begin
      FillChar(bfBtn, SizeOf(T3KButton), #0);
      MStream.Read(bfBtn, SizeOf(T3KButton));
      ReadGuiBase(bfBtn.Base, MinimizeBtn);
      ReadGuiBitMaps(MStream, bfBtn.BitMaps, MinimizeBtn.Bitmaps);
    end;
    MinimizeBtn.Visible := g_FileHeader.ControlVisible.MinimizeBtn;
    //--CloseBtn
    if g_FileHeader.ControlVisible.CloseBtn then begin
      FillChar(bfBtn, SizeOf(T3KButton), #0);
      MStream.Read(bfBtn, SizeOf(T3KButton));
      ReadGuiBase(bfBtn.Base, CloseBtn);
      ReadGuiBitMaps(MStream, bfBtn.BitMaps, CloseBtn.Bitmaps);
    end;
    CloseBtn.Visible := g_FileHeader.ControlVisible.CloseBtn;
    //----StartButton
    if g_FileHeader.ControlVisible.StartButton then begin
      FillChar(bfBtn, SizeOf(T3KButton), #0);
      MStream.Read(bfBtn, SizeOf(T3KButton));
      ReadGuiBase(bfBtn.Base, StartButton);
      ReadGuiBitMaps(MStream, bfBtn.BitMaps, StartButton.Bitmaps);
    end;
    StartButton.Visible := g_FileHeader.ControlVisible.StartButton;
    //----ButtonHomePage
    if g_FileHeader.ControlVisible.ButtonHomePage then begin
      FillChar(bfBtn, SizeOf(T3KButton), #0);
      MStream.Read(bfBtn, SizeOf(T3KButton));
      ReadGuiBase(bfBtn.Base, ButtonHomePage);
      ReadGuiBitMaps(MStream, bfBtn.BitMaps, ButtonHomePage.Bitmaps);
    end;
    ButtonHomePage.Visible := g_FileHeader.ControlVisible.ButtonHomePage;
    //----RzBmpButton1
    if g_FileHeader.ControlVisible.RzBmpButton1 then begin
      FillChar(bfBtn, SizeOf(T3KButton), #0);
      MStream.Read(bfBtn, SizeOf(T3KButton));
      ReadGuiBase(bfBtn.Base, RzBmpButton2);
      ReadGuiBitMaps(MStream, bfBtn.BitMaps, RzBmpButton2.Bitmaps);
    end;
    RzBmpButton2.Visible := g_FileHeader.ControlVisible.RzBmpButton1;
    //----RzBmpButton2
    if g_FileHeader.ControlVisible.RzBmpButton2 then begin
      FillChar(bfBtn, SizeOf(T3KButton), #0);
      MStream.Read(bfBtn, SizeOf(T3KButton));
      ReadGuiBase(bfBtn.Base, RzBmpButtonCancelPatch);
      ReadGuiBitMaps(MStream, bfBtn.BitMaps, RzBmpButtonCancelPatch.Bitmaps);
    end;
    RzBmpButtonCancelPatch.Visible := g_FileHeader.ControlVisible.RzBmpButton2;
    //----ButtonNewAccount
    if g_FileHeader.ControlVisible.ButtonNewAccount then begin
      FillChar(bfBtn, SizeOf(T3KButton), #0);
      MStream.Read(bfBtn, SizeOf(T3KButton));
      ReadGuiBase(bfBtn.Base, ButtonNewAccount);
      ReadGuiBitMaps(MStream, bfBtn.BitMaps, ButtonNewAccount.Bitmaps);
    end;
    ButtonNewAccount.Visible := g_FileHeader.ControlVisible.ButtonNewAccount;
    //----ButtonChgPassword
    if g_FileHeader.ControlVisible.ButtonChgPassword then begin
      FillChar(bfBtn, SizeOf(T3KButton), #0);
      MStream.Read(bfBtn, SizeOf(T3KButton));
      ReadGuiBase(bfBtn.Base, ButtonChgPassword);
      ReadGuiBitMaps(MStream, bfBtn.BitMaps, ButtonChgPassword.Bitmaps);
    end;
    ButtonChgPassword.Visible := g_FileHeader.ControlVisible.ButtonChgPassword;
    //----ButtonGetBackPassword
    if g_FileHeader.ControlVisible.ButtonGetBackPassword then begin
      FillChar(bfBtn, SizeOf(T3KButton), #0);
      MStream.Read(bfBtn, SizeOf(T3KButton));
      ReadGuiBase(bfBtn.Base, ButtonGetBackPassword);
      ReadGuiBitMaps(MStream, bfBtn.BitMaps, ButtonGetBackPassword.Bitmaps);
    end;
    ButtonGetBackPassword.Visible := g_FileHeader.ControlVisible.ButtonGetBackPassword;
    //----ImageButtonClose
    if g_FileHeader.ControlVisible.ImageButtonClose then begin
      FillChar(bfBtn, SizeOf(T3KButton), #0);
      MStream.Read(bfBtn, SizeOf(T3KButton));
      ReadGuiBase(bfBtn.Base, ImageButtonClose);
      ReadGuiBitMaps(MStream, bfBtn.BitMaps, ImageButtonClose.Bitmaps);
    end;
    ImageButtonClose.Visible := g_FileHeader.ControlVisible.ImageButtonClose;
    //----RzCheckBox1
    if g_FileHeader.ControlVisible.RzCheckBox1 then begin
      FillChar(bfCheckBox, SizeOf(T3KCheckBox), #0);
      MStream.Read(bfCheckBox, SizeOf(T3KCheckBox));
      ReadGuiBase(bfCheckBox.Base, RzCheckBox1);
      ReadGuiFont(bfCheckBox.Font, RzCheckBox1.Font);
      if bfCheckBox.Font.NameLen > 0 then begin
        SetLength(sText, bfCheckBox.Font.NameLen);
        MStream.Read(sText[1], bfCheckBox.Font.NameLen);
        RzCheckBox1.Font.Name := sText;
      end;
      RzCheckBox1.FrameColor := bfCheckBox.FrameColor;
      RzCheckBox1.HotTrackColor := bfCheckBox.HotTrackColor;
    end;
    RzCheckBox1.Visible := g_FileHeader.ControlVisible.RzCheckBox1;
    //----RzCombobox1
    if g_FileHeader.ControlVisible.RzComboBox1 then begin
      FillChar(bfRzComboBox, SizeOf(T3KRzComboBox), #0);
      MStream.Read(bfRzComboBox, SizeOf(T3KRzComboBox));
      ReadGuiBase(bfRzComboBox.Base, RzComboBox1);
      ReadGuiFont(bfRzComboBox.Font, RzComboBox1.Font);
      if bfRzComboBox.Font.NameLen > 0 then begin
        SetLength(sText, bfRzComboBox.Font.NameLen);
        MStream.Read(sText[1], bfRzComboBox.Font.NameLen);
        RzComboBox1.Font.Name := sText;
      end;
      RzComboBox1.FrameColor := bfRzComboBox.FrameColor;
      RzComboBox1.Color := bfRzComboBox.bColor;
    end;
    RzComboBox1.Visible := g_FileHeader.ControlVisible.RzComboBox1;
    //----RzCheckBoxFullScreen
    if g_FileHeader.ControlVisible.RzCheckBoxFullScreen then begin
      FillChar(bfCheckBox, SizeOf(T3KCheckBox), #0);
      MStream.Read(bfCheckBox, SizeOf(T3KCheckBox));
      ReadGuiBase(bfCheckBox.Base, RzCheckBoxFullScreen);
      ReadGuiFont(bfCheckBox.Font, RzCheckBoxFullScreen.Font);
      if bfCheckBox.Font.NameLen > 0 then begin
        SetLength(sText, bfCheckBox.Font.NameLen);
        MStream.Read(sText[1], bfCheckBox.Font.NameLen);
        RzCheckBoxFullScreen.Font.Name := sText;
      end;
      RzCheckBoxFullScreen.FrameColor := bfCheckBox.FrameColor;
      RzCheckBoxFullScreen.HotTrackColor := bfCheckBox.HotTrackColor;
    end;
    RzCheckBoxFullScreen.Visible := g_FileHeader.ControlVisible.RzCheckBoxFullScreen;
    //----RzLabelStatus
    if g_FileHeader.ControlVisible.RzLabelStatus then begin
      FillChar(bfLabel, SizeOf(T3KLabel), #0);
      MStream.Read(bfLabel, SizeOf(T3KLabel));
      ReadGuiBase(bfLabel.Base, RzLabelStatus);
      ReadGuiFont(bfLabel.Font, RzLabelStatus.Font);
      g_NormalLabelColor := bfLabel.Font.Color;
      if bfLabel.Font.NameLen > 0 then begin
        SetLength(sText, bfLabel.Font.NameLen);
        MStream.Read(sText[1], bfLabel.Font.NameLen);
        RzLabelStatus.Font.Name := sText;
      end;
      g_ConnectLabelColor := bfLabel.Color1;
      g_DisconnectLabelColor := bfLabel.Color2;
    end;
    RzLabelStatus.Visible := g_FileHeader.ControlVisible.RzLabelStatus;
    //----WebBrowser1
    if g_FileHeader.ControlVisible.WebBrowser1 then begin
      FillChar(bfWebBrowser, SizeOf(T3KWebBrowser), #0);
      MStream.Read(bfWebBrowser, SizeOf(T3KWebBrowser));
      ReadGuiBase(bfWebBrowser.Base, RzPanel1);
    end else RzPanel1.Visible := False;
    //----ProgressBarCurDownload
    if g_FileHeader.boProgressBarDown then begin
      if g_FileHeader.ControlVisible.ProgressBarCurDownload then begin
        FillChar(bfImageProgressBar, SizeOf(T3KImageProgressBar), #0);
        MStream.Read(bfImageProgressBar, SizeOf(T3KImageProgressBar));
        ReadGuiBase(bfImageProgressBar.Base, ProgressBarCurDownload);
        if bfImageProgressBar.BarImageLen > 0 then begin
          SetLength(sText, bfImageProgressBar.BarImageLen);
          MStream.Read(sText[1], bfImageProgressBar.BarImageLen);
          TempStream:= MakeStringIntoBitmap(sText);
          try
            TempStream.ReadBuffer(Buffer, 2);
            TempStream.Position := 0;
            if Buffer = $4D42 then begin //BMP
              if not Assigned(ProgressBarCurDownload.PicBar.Graphic) then ProgressBarCurDownload.PicBar.Bitmap := TBitmap.Create();
              ProgressBarCurDownload.PicBar.Bitmap.LoadFromStream(TempStream);
            end else if Buffer = $D8FF then begin //JPG
              if not Assigned(ProgressBarCurDownload.PicBar.Graphic) then ProgressBarCurDownload.PicBar.Graphic := TJpegImage.Create();
              ProgressBarCurDownload.PicBar.Graphic.LoadFromStream(TempStream);
            end else begin
              Application.MessageBox('进度条的滚动格图片只允许JPG和BMP格式！此图片没读取成功！',
                'Error', MB_OK + MB_ICONSTOP);
            end;
          finally
          	SetLength(sText, 0);
            TempStream.Free;
          end;
        end;
        if bfImageProgressBar.BfBarImageLen > 0 then begin
          SetLength(sText, bfImageProgressBar.BfBarImageLen);
          MStream.Read(sText[1], bfImageProgressBar.BfBarImageLen);
          TempStream:= MakeStringIntoBitmap(sText);
          try
            TempStream.ReadBuffer(Buffer, 2);
            TempStream.Position := 0;
            if Buffer = $4D42 then begin //BMP
              if not Assigned(ProgressBarCurDownload.PicMain.Graphic) then ProgressBarCurDownload.PicMain.Bitmap := TBitmap.Create();
              ProgressBarCurDownload.PicMain.Bitmap.LoadFromStream(TempStream);
            end else if Buffer = $D8FF then begin //JPG
              if not Assigned(ProgressBarCurDownload.PicMain.Graphic) then ProgressBarCurDownload.PicMain.Graphic := TJpegImage.Create();
              ProgressBarCurDownload.PicMain.Graphic.LoadFromStream(TempStream);
            end else begin
              Application.MessageBox('进度条的滚动格图片只允许JPG和BMP格式！此图片没读取成功！',
                'Error', MB_OK + MB_ICONSTOP);
            end;
          finally
            SetLength(sText, 0);
            TempStream.Free;
          end;
        end;
      end;
      ProgressBarCurDownload.Visible := g_FileHeader.ControlVisible.ProgressBarCurDownload;
    end else begin //----RzProgressBar1
      if g_FileHeader.ControlVisible.RzProgressBar1 then begin
        FillChar(bfRzProgressBar, SizeOf(T3KRzProgressBar), #0);
        MStream.Read(bfRzProgressBar, SizeOf(T3KRzProgressBar));
        ReadGuiBase(bfRzProgressBar.Base, RzProgressBarCurDownload);
        RzProgressBarCurDownload.BarStyle := bfRzProgressBar.BarStyle;
        RzProgressBarCurDownload.BackColor := bfRzProgressBar.BackColor;
        RzProgressBarCurDownload.FlatColor := bfRzProgressBar.FlatColor;
        RzProgressBarCurDownload.BarColor := bfRzProgressBar.BarColor;
      end;
      RzProgressBarCurDownload.Visible := g_FileHeader.ControlVisible.RzProgressBar1;
    end;
    //----ProgressBarAll
    if g_FileHeader.boProgressBarAll then begin
      if g_FileHeader.ControlVisible.ProgressBarAll then begin
        FillChar(bfImageProgressBar, SizeOf(T3KImageProgressBar), #0);
        MStream.Read(bfImageProgressBar, SizeOf(T3KImageProgressBar));
        ReadGuiBase(bfImageProgressBar.Base, ProgressBarAll);
        if bfImageProgressBar.BarImageLen > 0 then begin
          SetLength(sText, bfImageProgressBar.BarImageLen);
          MStream.Read(sText[1], bfImageProgressBar.BarImageLen);
          TempStream:= MakeStringIntoBitmap(sText);
          try
         	  TempStream.ReadBuffer(Buffer,2);
            TempStream.Position:= 0;
            if Buffer = $4D42 then begin //BMP
              if not Assigned(ProgressBarAll.PicBar.Graphic) then ProgressBarAll.PicBar.Bitmap := TBitmap.Create();
              ProgressBarAll.PicBar.Bitmap.LoadFromStream(TempStream);
            end else if Buffer = $D8FF then begin //JPG
              if not Assigned(ProgressBarAll.PicBar.Graphic) then ProgressBarAll.PicBar.Graphic := TJpegImage.Create();
              ProgressBarAll.PicBar.Graphic.LoadFromStream(TempStream);
            end else begin
              Application.MessageBox(PChar(SetDate('谗骨铭核儿範服鲁桑俅叟哜E_H德MB_服挪荒鲁桑檀刮钱计订')),
                'Error', MB_OK + MB_ICONSTOP);
            end;
          finally
          	SetLength(sText, 0);
            TempStream.Free;
          end;
        end;
        if bfImageProgressBar.BfBarImageLen > 0 then begin
          SetLength(sText, bfImageProgressBar.BfBarImageLen);
          MStream.Read(sText[1], bfImageProgressBar.BfBarImageLen);
          TempStream:= MakeStringIntoBitmap(sText);
          try
         	  TempStream.ReadBuffer(Buffer,2);
            TempStream.Position:= 0;
            if Buffer = $4D42 then begin //BMP
              if not Assigned(ProgressBarAll.PicMain.Graphic) then ProgressBarAll.PicMain.Bitmap := TBitmap.Create();
              ProgressBarAll.PicMain.Bitmap.LoadFromStream(MakeStringIntoBitmap(sText));
            end else if Buffer = $D8FF then begin //JPG
              if not Assigned(ProgressBarAll.PicMain.Graphic) then ProgressBarAll.PicMain.Graphic := TJpegImage.Create();
              ProgressBarAll.PicMain.Graphic.LoadFromStream(MakeStringIntoBitmap(sText));
            end else begin
              Application.MessageBox(PChar(SetDate('谗骨铭核炯笨鲁桑俅叟哜E_H德MB_服挪荒鲁桑檀刮钱计订')),
                'Error', MB_OK + MB_ICONSTOP);
            end;
          finally
            SetLength(sText, 0);
            TempStream.Free;
          end;
        end;
      end;
      ProgressBarAll.Visible := g_FileHeader.ControlVisible.ProgressBarAll;
    end else begin//----RzProgressBar2
      if g_FileHeader.ControlVisible.RzProgressBar2 then begin
        FillChar(bfRzProgressBar, SizeOf(T3KRzProgressBar), #0);
        MStream.Read(bfRzProgressBar, SizeOf(T3KRzProgressBar));
        ReadGuiBase(bfRzProgressBar.Base, RzProgressBarAll);
        //RzProgressBarAll.SetBounds(45,76,RzProgressBarAll.Width, RzProgressBarAll.Height);
        RzProgressBarAll.BarStyle := bfRzProgressBar.BarStyle;
        RzProgressBarAll.BackColor := bfRzProgressBar.BackColor;
        RzProgressBarAll.FlatColor := bfRzProgressBar.FlatColor;
        RzProgressBarAll.BarColor := bfRzProgressBar.BarColor;
      end;
      RzProgressBarAll.Visible := g_FileHeader.ControlVisible.RzProgressBar2;
    end;
  except
    Application.MessageBox(PChar(SetDate('刮钱喝筒渗色耕了绸浓坑')), 'Error', MB_OK + MB_ICONSTOP);
    Application.Terminate;
  end;
end;

procedure TFrmMain2.ComboBox1Change(Sender: TObject);
begin
  ServerActive;
end;

procedure TFrmMain2.LoadServerListView;
var
  ServerInfo: pTServerInfo;
  I:integer;
begin
  ComboBox1.Items.Clear;
  if g_ServerList.Count > 0 then begin
    for I := 0 to g_ServerList.Count - 1 do begin
      ServerInfo := pTServerInfo(g_ServerList.Items[I]);
      if ServerInfo <> nil then begin
        //ComboBox1.Items.Add(ServerInfo.ServerName);
        ComboBox1.Items.AddObject(ServerInfo.ServerName,TObject(ServerInfo));
      end;
    end;
    ComboBox1.ItemIndex := 0;
    ServerActive;
  end;
end;

//读出自身的信息
procedure TFrmMain2.LoadSelfInfo();
begin
  {$IF CLIENT_USEPE = 1}
  {$I CodeReplace_Start.inc}//WL虚拟机标识
  {$ELSE}
  asm
    db $EB,$10,'VMProtect begin',0
  end;
  {$IFEND}
  {$if Testing <> 0}
    ExtractInfo('C:\1.exe', MyRecInfo);//读出自身的信息
  {$ELSE}
    ExtractInfo(Application.ExeName, MyRecInfo);//读出自身的信息
  {$Ifend}
  if MyRecInfo.GameListURL <> '' then begin
    LnkName := MyRecInfo.lnkName;
    {$if GVersion = 1}
    g_sGameListURL := RSA1.DecryptStr(MyRecInfo.GameListURL);
    BakGameListURL := RSA1.DecryptStr(MyRecInfo.BakGameListURL);
    g_boGameMon := True;
    GameMonListURL := RSA1.DecryptStr(MyRecInfo.GameMonListURL);
    GameESystemURL := RSA1.DecryptStr(MyRecInfo.GameESystemUrl);
    ClientFileName := MyRecInfo.ClientFileName;
    g_sGatePassWord := MyRecInfo.GatePass;
    {$ifend}
    Application.Title := MyRecInfo.lnkName;
  end;
  //WriteInfo(PChar(g_sMirPath));
  {$if GVersion = 0}
  ClientFileName := '0.exe';
  //m_sLocalGameListName := '1.txt';
  {$IFEND}
  {$IF CLIENT_USEPE = 1}
  {$I CodeReplace_End.inc}
  {$ELSE}
  asm
    db $EB,$0E,'VMProtect end',0
  end;
  {$IFEND}
end;

end.
