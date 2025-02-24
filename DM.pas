unit DM;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs, FireDAC.VCLUI.Wait, Data.DB,
  DataSet.Serialize.Config, DataSet.Serialize, System.JSON,
  FireDAC.Comp.Client, Vcl.Dialogs, Vcl.Forms, System.IniFiles;

type
  TDtm = class(TDataModule)
    Conn: TFDConnection;
    procedure DataModuleCreate(Sender: TObject);
    procedure ConnBeforeConnect(Sender: TObject);
  private
  procedure CarregarConfigDB(Connection: TFDConnection);

    { Private declarations }
  public
    { Public declarations }
    function ListarDrivers(): TJsonArray;
    function ListarDriverID(const id_driver: integer): TJsonObject;
    function InsertDriver(name, cpf, phone, commission : string; percent_commission : Currency): TJsonObject;
    function UpdateDriver(id_driver: integer;  namedriver, cpf, phone, commission : string; percent_commission : Currency): TJsonObject;
    function ExcluirDriver(const id_driver: integer): TJsonObject;
    function DeleteDriver(const id_driver: integer): TJsonObject;

    function ListarVehicles(): TJsonArray;
    function InsertVehicle(plate, tipo, brand : string): TJsonObject;
    function UpdateVehicle(id_vehicle: integer;  plate, tipo, brand : string): TJsonObject;
    function DeleteVehicle(const id_vehicle: integer): TJsonObject;

    function ListarPoints(): TJsonArray;
    function InsertPoint(name, description, city, addres : string): TJsonObject;
    function UpdatePoint(id_point: integer;  namep, city, addres : string): TJsonObject;
    function DeletePoint(const id_point: integer): TJsonObject;

    function ListarOriginClient(id_client: integer): TJsonObject;
    function ListarDestineClient(id_client, id_origin: integer): TJsonObject;

    function ListarMaterial(): TJsonArray;
    function InsertMaterial(name: string): TJsonObject;
    function DeleteMaterial(const id_material: integer): TJsonObject;
    function ListarMaterialClient(id_client, id_origin, id_destination: integer): TJsonObject;


    function ListarServices(): TJsonArray;
    function InsertService(description: string): TJsonObject;

    function InsertActAbastecimento(id_driver, id_vehicle: integer; value_l_fuel, litros_fuel, value: Currency; local, km_vehicle: string): TJsonObject;
    function InsertActService(id_driver, id_vehicle: integer; value: Currency; description: string): TJsonObject;
    function InsertActTrips(id_driver, id_vehicle, id_material, id_origin, id_destination , id_client: integer; notafiscal: string; peso : Currency): TJsonObject;

    function ReportAbastecimento(const id_vehicle: integer; const firstdate, lastdate: TDateTime): TJSONObject;
    function ReportService(const id_vehicle: integer; const firstdate, lastdate: TDateTime): TJSONObject;
    function ReportTrip(const id_vehicle: integer; const firstdate, lastdate: TDateTime): TJSONObject;

    function ListarClients(): TJsonArray;
    function InsertClient(name, cnpj, phone : string): TJsonObject;
    function UpdateClient(id_client: integer; nameclient, cnpj, phone : string): TJsonObject;
    function DeleteClient(const id_client: integer): TJsonObject;

    function ListarRates(): TJsonArray;
    function ListarRateClient(id_client: integer): TJsonObject;
    function InsertRate(id_client, id_origin, id_destination, id_material: integer; rate, rate_driver : Currency): TJsonObject;
    function UpdateRate(id_rate, id_client, id_origin, id_destination, id_material: integer; rate, rate_driver : Currency): TJsonObject;
    function DeleteRate(const id_rate: integer): TJsonObject;



    function StatusBD: string;  // Fun��o que retorna o texto

  end;

var
  Dtm: TDtm;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

//Configuracao de conexao com BD
procedure TDtm.CarregarConfigDB(Connection: TFDConnection);
var
  IniFile: TIniFile;
  database: string;
  db: string;
begin

  // L� o arquivo .ini para obter o caminho do banco de dados
  IniFile := TIniFile.Create(ExtractFilePath(Application.ExeName) + 'config.ini');
  try
    // L� o valor da chave 'Path' na se��o 'Database'
    database:= IniFile.ReadString('API', 'BD', '');

    if database = '' then
    begin
      ShowMessage('Caminho do banco de dados n�o encontrado no arquivo .ini');
      Exit;
    end;

    db:= database;

    Connection.DriverName := 'SQLite';
    with Connection.Params do
    begin
        Clear;
        Add('DriverID=SQLite');

        Add('Database=' + db);
       //  Add('Database=C:\MONITOR REDE\BACKEND\DB\banco.db');
        Add('LockingMode=Normal'); // Par�metro opcional
        Add('Synchronous=Full');   // Par�metro opcional

    end;

  finally
    IniFile.Free;
  end;
end;

procedure TDtm.ConnBeforeConnect(Sender: TObject);
begin
    CarregarConfigDB(Conn);
end;

procedure TDtm.DataModuleCreate(Sender: TObject);
begin
    TDataSetSerializeConfig.GetInstance.CaseNameDefinition := cndLower;
    TDataSetSerializeConfig.GetInstance.Import.DecimalSeparator := '.';


    try
    Conn.Connected := true;
    except
    on E: Exception do
        begin
            // Trate o erro aqui
            ShowMessage('Verifique o caminho do servidor!');
            // Opcional: encerrar a aplica��o ou redirecionar o usu�rio
            Application.Terminate; // Ou voc� pode usar um exit para sair da rotina
        end;
    end;
end;

function TDtm.StatusBD: string;
begin
  //Se ele chegar ate aqui a Conexao com BD esta ok
  Result := 'CONECTADO';
end;



///////DRIVERS  (MOTORISTAS)
function TDtm.ListarDrivers(): TJsonArray;
var
    qry: TFDQuery;
begin
    try

        qry := TFDQuery.Create(nil);
        qry.Connection := Conn;

        qry.SQL.Add('SELECT * FROM tbl_drivers where excluded = :excluded');
        qry.ParamByName('excluded').Value := 'nao';
        qry.Open;

        Result := qry.ToJSONArray

    finally
        FreeAndNil(qry);
    end;
end;

function TDtm.ListarDriverID(const id_driver: integer): TJsonObject;
var
    qry: TFDQuery;

begin
    try
        qry := TFDQuery.Create(nil);
        qry.Connection := Conn;

        // Limpa o SQL para a inser��o do novo registro
        qry.Close;
        qry.SQL.Clear;

        qry.SQL.Add('SELECT * FROM tbl_drivers where id_driver = :id_driver and excluded = :excluded');
        qry.ParamByName('excluded').Value := 'nao';

        qry.ParamByName('id_driver').Value := id_driver;

        qry.open;
        //qry.ExecSQL;

        Result := qry.ToJsonObject;

    finally
        FreeAndNil(qry);
    end;
end;


function TDtm.InsertDriver(name, cpf, phone, commission : string; percent_commission : Currency): TJsonObject;
var
    qry: TFDQuery;
begin
    try
    qry := TFDQuery.Create(nil);
    qry.Connection := Conn;


    // Verificar se o nome j� existe
    qry.SQL.Text := 'SELECT id_driver FROM tbl_drivers WHERE name = :name and excluded = :excluded';
    qry.ParamByName('name').Value := name;
    qry.ParamByName('excluded').Value := 'nao';
    qry.Open;

    if qry.IsEmpty then
    begin
      // Se n�o existir, insere o novo motorista
      qry.Close;
      qry.SQL.Clear;
      qry.SQL.Add('INSERT INTO tbl_drivers (name, cpf, phone, commission, percent_commission, excluded) VALUES (:name, :cpf, :phone, :commission, :percent_commission, :excluded)');
      qry.ParamByName('name').Value := name;
      qry.ParamByName('cpf').Value := cpf;
      qry.ParamByName('phone').Value := phone;
      qry.ParamByName('commission').Value := commission;
      qry.ParamByName('percent_commission').Value := percent_commission;
      qry.ParamByName('excluded').Value := 'nao';
      qry.ExecSQL;

      // Retorna o ID do novo motorista
      qry.SQL.Clear;
      qry.SQL.Add('SELECT * FROM tbl_drivers WHERE name = :name');
      qry.ParamByName('name').Value := name;
      qry.Open;
    end
    else
    begin
      // Se j� existir, retorna o motorista existente
      qry.Close;
      qry.SQL.Clear;
      qry.SQL.Add('SELECT * FROM tbl_drivers WHERE name = :name');
      qry.ParamByName('name').Value := name;
      qry.Open;
    end;

    Result := qry.ToJsonObject;

  finally
    FreeAndNil(qry);
  end;
end;


function TDtm.UpdateDriver(id_driver: integer;  namedriver, cpf, phone, commission : string; percent_commission : Currency): TJsonObject;
var
    qry: TFDQuery;

begin
    try
        qry := TFDQuery.Create(nil);
        qry.Connection := Conn;

        // Valida��o dos par�metros
        if id_driver <= 0 then
        raise Exception.Create('ID do motorista inv�lido.');

        if Trim(name) = '' then
        raise Exception.Create('O nome do motorista n�o pode estar vazio.');

        if Length(name) > 50 then
        raise Exception.Create('O nome do motorista excede o limite de 50 caracteres.');

         // Verifica se o motorista existe antes de atualizar
        qry.SQL.Text := 'SELECT COUNT(*) FROM tbl_drivers WHERE id_driver = :id_driver';
        qry.ParamByName('id_driver').AsInteger := id_driver;
        qry.Open;

        if qry.Fields[0].AsInteger = 0 then
        raise Exception.Create('Motorista com o ID fornecido n�o existe.');

        with qry do
        begin

        // Limpa o SQL para a inser��o do novo registro
        qry.Close;
        qry.SQL.Clear;

        qry.SQL.Add('update tbl_drivers set name = :name, cpf= :cpf, phone = :phone, commission = :commission, percent_commission = :percent_commission ');
        qry.SQL.Add('where id_driver = :id_driver');


         qry.ParamByName('name').Value := namedriver;
         qry.ParamByName('id_driver').AsInteger := id_driver;
         qry.ParamByName('cpf').Value := cpf;
         qry.ParamByName('phone').Value := phone;
         qry.ParamByName('commission').Value := commission;
         qry.ParamByName('percent_commission').Value := percent_commission;

        //qry.open;
        qry.ExecSQL;
        end;

        Result := qry.ToJsonObject;

          // Retorna um JSON com a resposta (se necess�rio)
          Result := TJsonObject.Create;
          Result.AddPair('status', 'success');
          Result.AddPair('message', 'Motorista atualizado com sucesso.');
          Result.AddPair('name', namedriver);
          Result.AddPair('id_driver', TJSONNumber.Create(id_driver));

    finally
        FreeAndNil(qry);
    end;
end;


function TDtm.ExcluirDriver(const id_driver: integer): TJsonObject;
var
    qry: TFDQuery;
begin
   try
        qry := TFDQuery.Create(nil);
        qry.Connection := Conn;

        try
           Conn.StartTransaction;

           // Verifica se o registro existe antes de deletar
            qry.SQL.Add('SELECT id_driver FROM tbl_drivers WHERE id_driver = :id_driver and excluded = :excluded');
            qry.ParamByName('id_driver').Value := id_driver;
            qry.ParamByName('excluded').Value := 'nao';
            qry.Open;

            if qry.IsEmpty then
            begin
                Conn.Rollback;
                raise Exception.Create('Registro n�o encontrado.');
            end;

           qry.Close;
           qry.SQL.Clear;

           qry.SQL.Add('update tbl_drivers set excluded = :excluded');
           qry.SQL.Add('where id_driver = :id_driver');

           qry.ParamByName('id_driver').Value := id_driver;
           qry.ParamByName('excluded').Value := 'sim';
           qry.ExecSQL;

            Conn.Commit;
            Result := qry.ToJsonObject;
        except
            on ex: Exception do
            begin
                Conn.Rollback;
                raise Exception.Create(' Erro ao excluir o registro: ' + ex.Message);
            end;
        end;


    finally
        FreeAndNil(qry);
    end;
end;


function TDtm.DeleteDriver(const id_driver: integer): TJsonObject;
var
    qry: TFDQuery;
begin
   try
        qry := TFDQuery.Create(nil);
        qry.Connection := Conn;

        try
           Conn.StartTransaction;

           // Verifica se o registro existe antes de deletar
            qry.SQL.Add('SELECT id_driver FROM tbl_drivers WHERE id_driver = :id_driver and excluded = :excluded');
            qry.ParamByName('id_driver').Value := id_driver;
            qry.ParamByName('excluded').Value := 'nao';
            qry.Open;

            if qry.IsEmpty then
            begin
                Conn.Rollback;
                raise Exception.Create('Registro n�o encontrado.');
            end;

           qry.Close;
           qry.SQL.Clear;
           qry.SQL.Add('DELETE FROM tbl_drivers where id_driver = :id_driver');
           qry.ParamByName('id_driver').Value := id_driver;
           qry.ExecSQL;

            Conn.Commit;
            Result := qry.ToJsonObject;
        except
            on ex: Exception do
            begin
                Conn.Rollback;
                raise Exception.Create(' Erro ao excluir o registro: ' + ex.Message);
            end;
        end;


    finally
        FreeAndNil(qry);
    end;
end;


///////VHEICLES (VEICULOS)
function TDtm.ListarVehicles(): TJsonArray;
var
    qry: TFDQuery;
begin
    try

        qry := TFDQuery.Create(nil);
        qry.Connection := Conn;

        qry.SQL.Add('SELECT * FROM tbl_vehicles');
        qry.Open;

        Result := qry.ToJSONArray

    finally
        FreeAndNil(qry);
    end;
end;


function TDtm.InsertVehicle(plate, tipo, brand : string): TJsonObject;
var
    qry: TFDQuery;
begin
    try
    qry := TFDQuery.Create(nil);
    qry.Connection := Conn;


    // Verificar se a placa ja existe
    qry.SQL.Text := 'SELECT id_vehicle FROM tbl_vehicles WHERE plate = :plate';
    qry.ParamByName('plate').Value := plate;
    qry.Open;

    if qry.IsEmpty then
    begin
      // Se n�o existir, insere o novo motorista
      qry.Close;
      qry.SQL.Clear;
      qry.SQL.Add('INSERT INTO tbl_vehicles (plate, tipo, brand) VALUES (:plate, :tipo, :brand)');
      qry.ParamByName('plate').Value := plate;
      qry.ParamByName('tipo').Value := tipo;
      qry.ParamByName('brand').Value := brand;
      qry.ExecSQL;

      // Retorna o ID do novo motorista
      qry.SQL.Clear;
      qry.SQL.Add('SELECT * FROM tbl_vehicles WHERE plate = :plate');
      qry.ParamByName('plate').Value := plate;
      qry.Open;
    end
    else
    begin
      // Se j� existir, retorna o motorista existente
      qry.Close;
      qry.SQL.Clear;
      qry.SQL.Add('SELECT * FROM tbl_vehicles WHERE plate = :plate');
      qry.ParamByName('plate').Value := plate;
      qry.Open;
    end;

    Result := qry.ToJsonObject;

  finally
    FreeAndNil(qry);
  end;
end;



function TDtm.UpdateVehicle(id_vehicle: integer;  plate, tipo, brand : string): TJsonObject;
var
    qry: TFDQuery;

begin
    try
        qry := TFDQuery.Create(nil);
        qry.Connection := Conn;

        // Valida��o dos par�metros
        if id_vehicle <= 0 then
        raise Exception.Create('ID do Veiculo inv�lido.');

        if Trim(plate) = '' then
        raise Exception.Create('Informe a Placa do Veiculo.');

        if Length(plate) > 10 then
        raise Exception.Create('Placa maior doque 10 Caracteres.');

         // Verifica se o motorista existe antes de atualizar
        qry.SQL.Text := 'SELECT COUNT(*) FROM tbl_vehicles WHERE id_vehicle = :id_vehicle';
        qry.ParamByName('id_vehicle').AsInteger := id_vehicle;
        qry.Open;

        if qry.Fields[0].AsInteger = 0 then
        raise Exception.Create('Veiculo com o ID fornecido n�o existe.');

        with qry do
        begin

        // Limpa o SQL para a inser��o do novo registro
        qry.Close;
        qry.SQL.Clear;

        qry.SQL.Add('update tbl_vehicles set plate = :plate, tipo= :tipo, brand= :brand');
        qry.SQL.Add('where id_vehicle = :id_vehicle');


         qry.ParamByName('plate').Value := plate;
         qry.ParamByName('tipo').Value := tipo;
         qry.ParamByName('brand').Value := brand;
         qry.ParamByName('id_vehicle').AsInteger := id_vehicle;

        //qry.open;
        qry.ExecSQL;
        end;

        Result := qry.ToJsonObject;

          // Retorna um JSON com a resposta (se necess�rio)
          Result := TJsonObject.Create;
          Result.AddPair('status', 'success');
          Result.AddPair('message', 'Motorista atualizado com sucesso.');
          Result.AddPair('name', plate);
          Result.AddPair('id_driver', TJSONNumber.Create(id_vehicle));

    finally
        FreeAndNil(qry);
    end;
end;


function TDtm.DeleteVehicle(const id_vehicle: integer): TJsonObject;
var
    qry: TFDQuery;
begin
   try
        qry := TFDQuery.Create(nil);
        qry.Connection := Conn;

        try
           Conn.StartTransaction;

           // Verifica se o registro existe antes de deletar
            qry.SQL.Add('SELECT id_vehicle FROM tbl_vehicles WHERE id_vehicle = :id_vehicle');
            qry.ParamByName('id_vehicle').Value := id_vehicle;
            qry.Open;

            if qry.IsEmpty then
            begin
                Conn.Rollback;
                raise Exception.Create('Registro n�o encontrado.');
            end;

           qry.Close;
           qry.SQL.Clear;
           qry.SQL.Add('DELETE FROM tbl_vehicles where id_vehicle = :id_vehicle');
           qry.ParamByName('id_vehicle').Value := id_vehicle;
           qry.ExecSQL;

            Conn.Commit;
            Result := qry.ToJsonObject;
        except
            on ex: Exception do
            begin
                Conn.Rollback;
                raise Exception.Create(' Erro ao excluir o registro: ' + ex.Message);
            end;
        end;


    finally
        FreeAndNil(qry);
    end;
end;


///////POINTS (PONTOS DE COLETA E DESPEJO)
function TDtm.ListarPoints(): TJsonArray;
var
    qry: TFDQuery;
begin
    try

        qry := TFDQuery.Create(nil);
        qry.Connection := Conn;

        qry.SQL.Add('SELECT * FROM tbl_point');
        qry.Open;

        Result := qry.ToJSONArray

    finally
        FreeAndNil(qry);
    end;
end;





function TDtm.InsertPoint(name, description, city, addres : string): TJsonObject;
var
    qry: TFDQuery;
begin
    try
    qry := TFDQuery.Create(nil);
    qry.Connection := Conn;


    // Verificar se o nome j� existe
    qry.SQL.Text := 'SELECT id_point FROM tbl_point WHERE name = :name';
    qry.ParamByName('name').Value := name;
    qry.Open;

    if qry.IsEmpty then
    begin
      // Se n�o existir, insere o novo motorista
      qry.Close;
      qry.SQL.Clear;
      qry.SQL.Add('INSERT INTO tbl_point (name, description, city, addres) VALUES (:name, :description, :city, :addres)');
      qry.ParamByName('name').Value := name;
      qry.ParamByName('description').Value := description;
      qry.ParamByName('city').Value := city;
      qry.ParamByName('addres').Value := addres;
      qry.ExecSQL;

      // Retorna o ID do novo motorista
      qry.SQL.Clear;
      qry.SQL.Add('SELECT * FROM tbl_point WHERE name = :name');
      qry.ParamByName('name').Value := name;
      qry.Open;
    end
    else
    begin
      // Se j� existir, retorna o motorista existente
      qry.Close;
      qry.SQL.Clear;
      qry.SQL.Add('SELECT * FROM tbl_point WHERE name = :name');
      qry.ParamByName('name').Value := name;
      qry.Open;
    end;

    Result := qry.ToJsonObject;

  finally
    FreeAndNil(qry);
  end;
end;


function TDtm.UpdatePoint(id_point: integer;  namep, city, addres : string): TJsonObject;
var
    qry: TFDQuery;

begin
    try
        qry := TFDQuery.Create(nil);
        qry.Connection := Conn;

        // Valida��o dos par�metros
        if id_point <= 0 then
        raise Exception.Create('ID do Ponto inv�lido.');

        if Trim(name) = '' then
        raise Exception.Create('Informe o nome do Ponto.');

        if Length(name) > 50 then
        raise Exception.Create('Nome excede o limite de 50 caracteres');

         // Verifica se o motorista existe antes de atualizar
        qry.SQL.Text := 'SELECT COUNT(*) FROM tbl_point WHERE id_point = :id_point';
        qry.ParamByName('id_point').AsInteger := id_point;
        qry.Open;

        if qry.Fields[0].AsInteger = 0 then
        raise Exception.Create('Ponto com o ID fornecido n�o existe.');

        with qry do
        begin

        // Limpa o SQL para a inser��o do novo registro
        qry.Close;
        qry.SQL.Clear;

        qry.SQL.Add('update tbl_point set name = :name, city= :city, addres= :addres');
        qry.SQL.Add('where id_point = :id_point');


         qry.ParamByName('name').Value := namep;
         qry.ParamByName('city').Value := city;
         qry.ParamByName('addres').Value := addres;
         qry.ParamByName('id_point').AsInteger := id_point;

        //qry.open;
        qry.ExecSQL;
        end;

        Result := qry.ToJsonObject;

          // Retorna um JSON com a resposta (se necess�rio)
          Result := TJsonObject.Create;
          Result.AddPair('status', 'success');
          Result.AddPair('message', 'Ponto atualizado com sucesso.');
          Result.AddPair('name', namep);
          Result.AddPair('id_point', TJSONNumber.Create(id_point));

    finally
        FreeAndNil(qry);
    end;
end;

function TDtm.DeletePoint(const id_point: integer): TJsonObject;
var
    qry: TFDQuery;
begin
   try
        qry := TFDQuery.Create(nil);
        qry.Connection := Conn;

        try
           Conn.StartTransaction;

           // Verifica se o registro existe antes de deletar
            qry.SQL.Add('SELECT id_point FROM tbl_point WHERE id_point = :id_point');
            qry.ParamByName('id_point').Value := id_point;
            qry.Open;

            if qry.IsEmpty then
            begin
                Conn.Rollback;
                raise Exception.Create('Registro n�o encontrado.');
            end;

           qry.Close;
           qry.SQL.Clear;
           qry.SQL.Add('DELETE FROM tbl_point where id_point = :id_point');
           qry.ParamByName('id_point').Value := id_point;
           qry.ExecSQL;

            Conn.Commit;
            Result := qry.ToJsonObject;
        except
            on ex: Exception do
            begin
                Conn.Rollback;
                raise Exception.Create(' Erro ao excluir o registro: ' + ex.Message);
            end;
        end;


    finally
        FreeAndNil(qry);
    end;
end;





function TDtm.ListarOriginClient(id_client: integer): TJsonObject;
var
    qry: TFDQuery;
    jsonObject: TJsonObject;
    jsonArray: TJsonArray;
    field: TField;
begin
    try

        qry := TFDQuery.Create(nil);
        qry.Connection := Conn;

        qry.SQL.Add('SELECT id_rate, p.id_point, p.name');
        qry.SQL.Add('FROM tbl_rates r');
        qry.SQL.Add('LEFT JOIN tbl_point p ON p.id_point = r.id_origin');
        qry.SQL.Add('where r.id_client = :id_client');

        qry.ParamByName('id_client').Value := id_client;
        qry.Open;

        jsonArray := TJsonArray.Create;
    try
      while not qry.Eof do
      begin
        jsonObject := TJsonObject.Create;
        try
          // Adiciona todos os campos da consulta ao objeto JSON
          for field in qry.Fields do
          begin
            jsonObject.AddPair(field.FieldName, field.AsString);
          end;

          // Adiciona o objeto ao array
          jsonArray.AddElement(jsonObject);

          qry.Next;
        except
          jsonObject.Free;
          raise;
        end;
      end;

       // Cria o resultado final
      Result := TJsonObject.Create;
      Result.AddPair('origin', jsonArray);
    except
      jsonArray.Free;
      raise;
    end;
  finally
    qry.Free;
  end;
end;

function TDtm.ListarDestineClient(id_client, id_origin: integer): TJsonObject;
var
    qry: TFDQuery;
    jsonObject: TJsonObject;
    jsonArray: TJsonArray;
    field: TField;
begin
    try

        qry := TFDQuery.Create(nil);
        qry.Connection := Conn;

        qry.SQL.Add('SELECT id_rate, p.id_point, p.name');
        qry.SQL.Add('FROM tbl_rates r');
        qry.SQL.Add('LEFT JOIN tbl_point p ON p.id_point = r.id_destination');
        qry.SQL.Add('where r.id_client = :id_client and r.id_origin = :id_origin');

        qry.ParamByName('id_client').Value := id_client;
        qry.ParamByName('id_origin').Value := id_origin;
        qry.Open;

        jsonArray := TJsonArray.Create;
    try
      while not qry.Eof do
      begin
        jsonObject := TJsonObject.Create;
        try
          // Adiciona todos os campos da consulta ao objeto JSON
          for field in qry.Fields do
          begin
            jsonObject.AddPair(field.FieldName, field.AsString);
          end;

          // Adiciona o objeto ao array
          jsonArray.AddElement(jsonObject);

          qry.Next;
        except
          jsonObject.Free;
          raise;
        end;
      end;

       // Cria o resultado final
      Result := TJsonObject.Create;
      Result.AddPair('destine', jsonArray);
    except
      jsonArray.Free;
      raise;
    end;
  finally
    qry.Free;
  end;
end;


///////MATERIAL
function TDtm.ListarMaterial(): TJsonArray;
var
    qry: TFDQuery;
begin
    try

        qry := TFDQuery.Create(nil);
        qry.Connection := Conn;

        qry.SQL.Add('SELECT * FROM tbl_material');
        qry.Open;

        Result := qry.ToJSONArray

    finally
        FreeAndNil(qry);
    end;
end;


function TDtm.InsertMaterial(name : string): TJsonObject;
var
    qry: TFDQuery;
begin
    try
    qry := TFDQuery.Create(nil);
    qry.Connection := Conn;


    // Verificar se o nome j� existe
    qry.SQL.Text := 'SELECT id_material FROM tbl_material WHERE name = :name';
    qry.ParamByName('name').Value := name;
    qry.Open;

    if qry.IsEmpty then
    begin
      // Se n�o existir, insere o novo motorista
      qry.Close;
      qry.SQL.Clear;
      qry.SQL.Add('INSERT INTO tbl_material (name) VALUES (:name)');
      qry.ParamByName('name').Value := name;

      qry.ExecSQL;

      // Retorna o ID do novo motorista
      qry.SQL.Clear;
      qry.SQL.Add('SELECT * FROM tbl_material WHERE name = :name');
      qry.ParamByName('name').Value := name;
      qry.Open;
    end
    else
    begin
      // Se j� existir, retorna o motorista existente
      qry.Close;
      qry.SQL.Clear;
      qry.SQL.Add('SELECT * FROM tbl_material WHERE name = :name');
      qry.ParamByName('name').Value := name;
      qry.Open;
    end;

    Result := qry.ToJsonObject;

  finally
    FreeAndNil(qry);
  end;
end;


function TDtm.DeleteMaterial(const id_material: integer): TJsonObject;
var
    qry: TFDQuery;
begin
   try
        qry := TFDQuery.Create(nil);
        qry.Connection := Conn;

        try
           Conn.StartTransaction;

           // Verifica se o registro existe antes de deletar
            qry.SQL.Add('SELECT id_material FROM tbl_material WHERE id_material = :id_material');
            qry.ParamByName('id_material').Value := id_material;
            qry.Open;

            if qry.IsEmpty then
            begin
                Conn.Rollback;
                raise Exception.Create('Registro n�o encontrado.');
            end;

           qry.Close;
           qry.SQL.Clear;
           qry.SQL.Add('DELETE FROM tbl_material where id_material = :id_material');
           qry.ParamByName('id_material').Value := id_material;
           qry.ExecSQL;

            Conn.Commit;
            Result := qry.ToJsonObject;
        except
            on ex: Exception do
            begin
                Conn.Rollback;
                raise Exception.Create(' Erro ao excluir o registro: ' + ex.Message);
            end;
        end;


    finally
        FreeAndNil(qry);
    end;
end;


function TDtm.ListarMaterialClient(id_client, id_origin, id_destination: integer): TJsonObject;
var
    qry: TFDQuery;
    jsonObject: TJsonObject;
    jsonArray: TJsonArray;
    field: TField;
begin
    try

        qry := TFDQuery.Create(nil);
        qry.Connection := Conn;

        qry.SQL.Add('SELECT id_rate, m.id_material, m.name');
        qry.SQL.Add('FROM tbl_rates r');
        qry.SQL.Add('LEFT JOIN tbl_material m ON m.id_material = r.id_material');
        qry.SQL.Add('where r.id_client = :id_client and r.id_origin = :id_origin and r.id_destination = :id_destination');

        qry.ParamByName('id_client').Value := id_client;
        qry.ParamByName('id_origin').Value := id_origin;
        qry.ParamByName('id_destination').Value := id_destination;
        qry.Open;

        jsonArray := TJsonArray.Create;
    try
      while not qry.Eof do
      begin
        jsonObject := TJsonObject.Create;
        try
          // Adiciona todos os campos da consulta ao objeto JSON
          for field in qry.Fields do
          begin
            jsonObject.AddPair(field.FieldName, field.AsString);
          end;

          // Adiciona o objeto ao array
          jsonArray.AddElement(jsonObject);

          qry.Next;
        except
          jsonObject.Free;
          raise;
        end;
      end;

       // Cria o resultado final
      Result := TJsonObject.Create;
      Result.AddPair('mater', jsonArray);
    except
      jsonArray.Free;
      raise;
    end;
  finally
    qry.Free;
  end;
end;


///////SERVICOS
function TDtm.ListarServices(): TJsonArray;
var
    qry: TFDQuery;
begin
    try

        qry := TFDQuery.Create(nil);
        qry.Connection := Conn;

        qry.SQL.Add('SELECT * FROM tbl_service');
        qry.Open;

        Result := qry.ToJSONArray

    finally
        FreeAndNil(qry);
    end;
end;


function TDtm.InsertService(description : string): TJsonObject;
var
    qry: TFDQuery;
begin
    try
    qry := TFDQuery.Create(nil);
    qry.Connection := Conn;




      // Se n�o existir, insere o novo motorista
      qry.Close;
      qry.SQL.Clear;
      qry.SQL.Add('INSERT INTO tbl_service (description) VALUES (:description)');
      qry.ParamByName('description').Value := description;

      qry.ExecSQL;

      // Retorna o ID do novo motorista
      qry.SQL.Clear;
      qry.SQL.Add('SELECT * FROM tbl_service WHERE description = :description');
      qry.ParamByName('description').Value := description;
      qry.Open;



    Result := qry.ToJsonObject;

  finally
    FreeAndNil(qry);
  end;
end;


//////  ACTION //////
function TDtm.InsertActAbastecimento(id_driver, id_vehicle: integer; value_l_fuel, litros_fuel, value: Currency; local, km_vehicle: string): TJsonObject;
var
  qry: TFDQuery;
begin
  try
    qry := TFDQuery.Create(nil);
    qry.Connection := Conn;

    // Insere os dados na tabela
    qry.SQL.Text := 'INSERT INTO tbl_act_abastecimento (id_driver, id_vehicle, km_vehicle, value_l_fuel, litros_fuel, value, local, date) ' +
                    'VALUES (:id_driver, :id_vehicle, :km_vehicle, :value_l_fuel, :litros_fuel, :value, :local, :date)';
    qry.ParamByName('id_driver').Value := id_driver;
    qry.ParamByName('id_vehicle').Value := id_vehicle;

    qry.ParamByName('km_vehicle').Value := km_vehicle;
    qry.ParamByName('value_l_fuel').Value := value_l_fuel;
    qry.ParamByName('litros_fuel').Value := litros_fuel;
    qry.ParamByName('value').Value := value;  // Passando o valor como Currency
    qry.ParamByName('local').Value := local;
    qry.ParamByName('date').Value := FormatDateTime('yyyy-mm-dd HH:nn:ss', now);

    qry.ExecSQL;

    // Retorna um JSON com a resposta (se necess�rio)
    Result := TJsonObject.Create;
    Result.AddPair('status', 'success');
    Result.AddPair('message', 'Abastecimento registrado com sucesso.');
  finally
    FreeAndNil(qry);
  end;
end;


// Fun��o que realiza a inser��o dos dados de uma viagem (Insert)
function TDtm.InsertActService(id_driver, id_vehicle: integer; value: Currency; description: string): TJsonObject;
var
  qry: TFDQuery;
begin
  try
    qry := TFDQuery.Create(nil);
    qry.Connection := Conn;

    // Iniciar uma transa��o
    Conn.StartTransaction;

    // Inserir os dados na tabela tbl_trips
    qry.SQL.Text := 'INSERT INTO tbl_act_service (id_driver, id_vehicle, value, description, date) ' +
                    'VALUES (:id_driver, :id_vehicle, :value, :description, :date)';
    qry.ParamByName('id_driver').Value := id_driver;
    qry.ParamByName('id_vehicle').Value := id_vehicle;
    qry.ParamByName('value').Value := value; // O valor monet�rio em Real
    qry.ParamByName('description').Value := description;
    qry.ParamByName('date').Value := FormatDateTime('yyyy-mm-dd HH:nn:ss', now);

    qry.ExecSQL;

    // Commit da transa��o
    Conn.Commit;

    // Retorna um JSON com o status de sucesso
    Result := TJsonObject.Create;
    Result.AddPair('status', 'success');
    Result.AddPair('message', 'Servi�o registrada com sucesso');
  except
    on E: Exception do
    begin
      // Caso ocorra um erro, faz o rollback e retorna a mensagem de erro
      Conn.Rollback;
      Result := TJsonObject.Create;
      Result.AddPair('status', 'error');
      Result.AddPair('message', 'Erro ao registrar Servi�o: ' + E.Message);
    end;
  end;
end;


// Fun��o para inserir dados de viagem
function TDtm.InsertActTrips(id_driver, id_vehicle, id_material, id_origin, id_destination, id_client: integer; notafiscal : string; peso: Currency): TJsonObject;
var
  qry, qryDriver, qryRate: TFDQuery;
  percent_commission, rate, rate_driver, percent: Double;
begin
  try
    qry := TFDQuery.Create(nil);
    qryDriver := TFDQuery.Create(nil);
    qryRate := TFDQuery.Create(nil);

    qry.Connection := Conn;
    qryDriver.Connection := Conn;
    qryRate.Connection := Conn;

    // Iniciar uma transa��o
    Conn.StartTransaction;

    // Consultar o percent_commission do driver
    qryDriver.SQL.Text := 'SELECT percent_commission FROM tbl_drivers WHERE id_driver = :id_driver';
    qryDriver.ParamByName('id_driver').Value := id_driver;
    qryDriver.Open;

    // Verificar se foi encontrado o valor
    if not qryDriver.Eof then
      percent_commission := qryDriver.FieldByName('percent_commission').AsFloat
    else
      raise Exception.Create('Motorista n�o encontrado.');


     // Consultar o percent_commission do driver
    qryDriver.SQL.Text := 'SELECT rate, rate_driver FROM tbl_rates WHERE id_client = :id_client and id_origin = :id_origin and id_destination = :id_destination';
    qryDriver.ParamByName('id_client').Value := id_client;
    qryDriver.ParamByName('id_origin').Value := id_origin;
    qryDriver.ParamByName('id_destination').Value := id_destination;
    qryDriver.Open;

    // Verificar se foi encontrado o valor
    if not qryDriver.Eof then
    begin
      rate := qryDriver.FieldByName('rate').AsFloat;
      rate_driver := qryDriver.FieldByName('rate_driver').AsFloat;
    end
    else
      raise Exception.Create('Tarifa n�o encontrado.');

    // Inserir os dados na tabela tbl_trips
    qry.SQL.Text := 'INSERT INTO tbl_act_trips (id_driver, id_vehicle, id_material, id_origin, id_destination, peso, notafiscal, id_client, rate, rate_driver, commission, value_liquido, value_driver, date) ' +
                    'VALUES (:id_driver, :id_vehicle, :id_material, :id_origin, :id_destination, :peso, :notafiscal, :id_client, :rate, :rate_driver, :commission, :value_liquido, :value_driver, :date)';
    qry.ParamByName('id_driver').Value := id_driver;
    qry.ParamByName('id_vehicle').Value := id_vehicle;
    qry.ParamByName('id_client').Value := id_client;
    qry.ParamByName('id_material').Value := id_material;
    qry.ParamByName('id_origin').Value := id_origin;
    qry.ParamByName('id_destination').Value := id_destination;
    qry.ParamByName('peso').Value := peso;  // O peso pode ser tratado como string (se for alfanum�rico)
    qry.ParamByName('notafiscal').Value := notafiscal;
    qry.ParamByName('date').Value := FormatDateTime('yyyy-mm-dd HH:nn:ss', now);

    qry.ParamByName('rate').Value := rate;
    qry.ParamByName('rate_driver').Value := rate_driver;
    qry.ParamByName('commission').Value := percent_commission;
    //percent := percent_commission /100;
    qry.ParamByName('value_liquido').Value := peso * rate;
    qry.ParamByName('value_driver').Value := (peso * rate_driver) * (percent_commission /100);



    qry.ExecSQL;

    // Commit da transa��o
    Conn.Commit;

    // Retorna um JSON com o status de sucesso
    Result := TJsonObject.Create;
    Result.AddPair('status', 'success');
    Result.AddPair('message', 'Viagem registrada com sucesso');
  except
    on E: Exception do
    begin
      // Caso ocorra um erro, faz o rollback e retorna a mensagem de erro
      Conn.Rollback;
      Result := TJsonObject.Create;
      Result.AddPair('status', 'error');
      Result.AddPair('message', 'Erro ao registrar viagem: ' + E.Message);
    end;
  end;
end;


{function TDtm.ReportAbastecimento(const id_vehicle: integer; const firstdate, lastdate: TDateTime): TJsonArray;
var
    qry: TFDQuery;
    DataFirt, DataLast: string;
    jsonObj: TJSONObject;
begin
    try
        qry := TFDQuery.Create(nil);
        qry.Connection := Conn;

        // Converter a data para o formato YYYY-MM-DD (SQLite usa esse formato para compara��es)
        DataFirt := FormatDateTime('yyyy-mm-dd', firstdate);
        DataLast := FormatDateTime('yyyy-mm-dd', lastdate);


        qry.SQL.Add('SELECT a.date, a.id_driver, d.name, a.id_vehicle, v.plate, km_vehicle, a.litros_fuel, a.value_l_fuel, a.value');
        qry.SQL.Add('FROM tbl_act_abastecimento a');
        qry.SQL.Add('JOIN tbl_drivers d ON a.id_driver = d.id_driver');
        qry.SQL.Add('JOIN tbl_vehicles v ON a.id_vehicle = v.id_vehicle');
        qry.SQL.Add('WHERE a.id_vehicle = :id_vehicle');
        qry.SQL.Add('AND DATE(a.date) BETWEEN :data_inicio AND :data_fim');
        qry.SQL.Add('ORDER BY a.date');

        qry.ParamByName('id_vehicle').Value := id_vehicle;
        qry.ParamByName('data_inicio').Value := DataFirt;
        qry.ParamByName('data_fim').Value := DataLast;
        qry.Open;

        Result := qry.ToJSONArray



    finally
        FreeAndNil(qry);
    end;
end;}


function TDtm.ReportAbastecimento(const id_vehicle: integer; const firstdate, lastdate: TDateTime): TJSONObject;
var
    qry: TFDQuery;
    DataFirt, DataLast: string;
    jsonObj: TJSONObject;
    jsonArray: TJsonArray;
    finalJson: TJSONObject;
    totalValue: Double;
    maxKm, minKm, totalKm: Double;
begin
    try
        qry := TFDQuery.Create(nil);
        qry.Connection := Conn;

        // Converter a data para o formato YYYY-MM-DD (SQLite usa esse formato para compara��es)
        DataFirt := FormatDateTime('yyyy-mm-dd', firstdate);
        DataLast := FormatDateTime('yyyy-mm-dd', lastdate);

        // Inicializa o array JSON e o objeto final
        jsonArray := TJSONArray.Create;
        finalJson := TJSONObject.Create;
        totalValue := 0;
        maxKm := 0;
        minKm := MaxInt; // Inicializar com o valor m�ximo de inteiro dispon�vel
        totalKm := 0;

        // Consulta os dados
        qry.SQL.Add('SELECT a.date, a.id_driver, d.name, a.id_vehicle, v.plate, km_vehicle, a.litros_fuel, a.value_l_fuel, a.value, a.local,');
        qry.SQL.Add('       (SELECT SUM(a2.value) FROM tbl_act_abastecimento a2 WHERE a2.id_vehicle = :id_vehicle AND DATE(a2.date) BETWEEN :data_inicio AND :data_fim) AS total_value');
        qry.SQL.Add('FROM tbl_act_abastecimento a');
        qry.SQL.Add('JOIN tbl_drivers d ON a.id_driver = d.id_driver');
        qry.SQL.Add('JOIN tbl_vehicles v ON a.id_vehicle = v.id_vehicle');
        qry.SQL.Add('WHERE a.id_vehicle = :id_vehicle');
        qry.SQL.Add('AND DATE(a.date) BETWEEN :data_inicio AND :data_fim');
        qry.SQL.Add('ORDER BY a.date');

        qry.ParamByName('id_vehicle').Value := id_vehicle;
        qry.ParamByName('data_inicio').Value := DataFirt;
        qry.ParamByName('data_fim').Value := DataLast;
        qry.Open;

        // Processa os resultados
        while not qry.Eof do
        begin
            // Atualiza maxKm e minKm
            if qry.FieldByName('km_vehicle').AsInteger > maxKm then
                maxKm := qry.FieldByName('km_vehicle').AsFloat;

            if qry.FieldByName('km_vehicle').AsInteger < minKm then
                minKm := qry.FieldByName('km_vehicle').AsFloat;

            // Calcula o total_value
            totalValue := qry.FieldByName('total_value').AsFloat;

            // Adiciona o registro ao JSON array
            jsonObj := TJSONObject.Create;
            jsonObj.AddPair('date', FormatDateTime('yyyy-mm-dd"T"hh:nn:ss.zzz"Z"', qry.FieldByName('date').AsDateTime));
            jsonObj.AddPair('id_driver', qry.FieldByName('id_driver').AsString);
            jsonObj.AddPair('name', qry.FieldByName('name').AsString);
            jsonObj.AddPair('id_vehicle', qry.FieldByName('id_vehicle').AsString);
            jsonObj.AddPair('plate', qry.FieldByName('plate').AsString);
            jsonObj.AddPair('local', qry.FieldByName('local').AsString);
            jsonObj.AddPair('km_vehicle', qry.FieldByName('km_vehicle').value);
            jsonObj.AddPair('litros_fuel', TJSONNumber.Create(qry.FieldByName('litros_fuel').AsFloat));
            jsonObj.AddPair('value_l_fuel', TJSONNumber.Create(qry.FieldByName('value_l_fuel').AsFloat));
            jsonObj.AddPair('value', TJSONNumber.Create(qry.FieldByName('value').AsFloat));

            jsonArray.AddElement(jsonObj);
            qry.Next;
        end;

        // Calcula o total_km
        if (maxKm > 0) and (minKm < MaxInt) then
            totalKm := maxKm - minKm;

        // Adiciona o array e os totais ao objeto final
        finalJson.AddPair('fuel', jsonArray);
        finalJson.AddPair('total_value', TJSONNumber.Create(totalValue));
        finalJson.AddPair('total_km', TJSONNumber.Create(totalKm));

        // Retorna o JSON final
        Result := finalJson;
    finally
        FreeAndNil(qry);
    end;
end;


function TDtm.ReportService(const id_vehicle: integer; const firstdate, lastdate: TDateTime): TJSONObject;
var
    qry: TFDQuery;
    DataFirt, DataLast: string;
    jsonObj: TJSONObject;
    jsonArray: TJsonArray;
    finalJson: TJSONObject;
    totalValue: Double;
begin
    try
        qry := TFDQuery.Create(nil);
        qry.Connection := Conn;

        // Converter a data para o formato YYYY-MM-DD (SQLite usa esse formato para compara��es)
        DataFirt := FormatDateTime('yyyy-mm-dd', firstdate);
        DataLast := FormatDateTime('yyyy-mm-dd', lastdate);

        // Inicializa o array JSON e o objeto final
        jsonArray := TJSONArray.Create;
        finalJson := TJSONObject.Create;
        totalValue := 0;


        // Consulta os dados
        qry.SQL.Add('SELECT a.date, a.id_driver, d.name, a.id_vehicle, v.plate, a.value, a.description,');
        qry.SQL.Add('       (SELECT SUM(a2.value) FROM tbl_act_service a2 WHERE a2.id_vehicle = :id_vehicle AND DATE(a2.date) BETWEEN :data_inicio AND :data_fim) AS total_value');
        qry.SQL.Add('FROM tbl_act_service a');
        qry.SQL.Add('JOIN tbl_drivers d ON a.id_driver = d.id_driver');
        qry.SQL.Add('JOIN tbl_vehicles v ON a.id_vehicle = v.id_vehicle');
        qry.SQL.Add('WHERE a.id_vehicle = :id_vehicle');
        qry.SQL.Add('AND DATE(a.date) BETWEEN :data_inicio AND :data_fim');
        qry.SQL.Add('ORDER BY a.date');

        qry.ParamByName('id_vehicle').Value := id_vehicle;
        qry.ParamByName('data_inicio').Value := DataFirt;
        qry.ParamByName('data_fim').Value := DataLast;
        qry.Open;

        // Processa os resultados
        while not qry.Eof do
        begin

            // Calcula o total_value
            totalValue := qry.FieldByName('total_value').AsFloat;

            // Adiciona o registro ao JSON array
            jsonObj := TJSONObject.Create;
            jsonObj.AddPair('date', FormatDateTime('yyyy-mm-dd"T"hh:nn:ss.zzz"Z"', qry.FieldByName('date').AsDateTime));
            jsonObj.AddPair('id_driver', qry.FieldByName('id_driver').AsString);
            jsonObj.AddPair('name', qry.FieldByName('name').AsString);
            jsonObj.AddPair('id_vehicle', qry.FieldByName('id_vehicle').AsString);
            jsonObj.AddPair('plate', qry.FieldByName('plate').AsString);
            jsonObj.AddPair('description', qry.FieldByName('description').AsString);

            jsonObj.AddPair('value', TJSONNumber.Create(qry.FieldByName('value').AsFloat));

            jsonArray.AddElement(jsonObj);
            qry.Next;
        end;

        // Adiciona o array e os totais ao objeto final
        finalJson.AddPair('service', jsonArray);
        finalJson.AddPair('total_value', TJSONNumber.Create(totalValue));

        // Retorna o JSON final
        Result := finalJson;
    finally
        FreeAndNil(qry);
    end;
end;

function TDtm.ReportTrip(const id_vehicle: integer; const firstdate, lastdate: TDateTime): TJSONObject;
var
    qry: TFDQuery;
    DataFirt, DataLast: string;
    jsonObj: TJSONObject;
    jsonArray: TJsonArray;
    finalJson: TJSONObject;

begin
    try
        qry := TFDQuery.Create(nil);
        qry.Connection := Conn;

        // Converter a data para o formato YYYY-MM-DD (SQLite usa esse formato para compara��es)
        DataFirt := FormatDateTime('yyyy-mm-dd', firstdate);
        DataLast := FormatDateTime('yyyy-mm-dd', lastdate);

        // Inicializa o array JSON e o objeto final
        jsonArray := TJSONArray.Create;
        finalJson := TJSONObject.Create;


        // Consulta os dados
        qry.SQL.Add('SELECT a.date, a.id_driver, d.name, a.id_vehicle, v.plate, a.id_material, m.name As material, a.id_origin, p.name As origin, p2.name As destination, a.id_destination, a.peso,');
        qry.SQL.Add('a.notafiscal, a.rate, a.rate_driver, a.commission, a.value_liquido, a.value_driver ');
        qry.SQL.Add('FROM tbl_act_trips a');
        qry.SQL.Add('JOIN tbl_drivers d ON a.id_driver = d.id_driver');
        qry.SQL.Add('JOIN tbl_vehicles v ON a.id_vehicle = v.id_vehicle');

        qry.SQL.Add('JOIN tbl_point p ON a.id_origin = p.id_point');
        qry.SQL.Add('JOIN tbl_point p2 ON a.id_destination = p2.id_point');
        qry.SQL.Add('JOIN tbl_material m ON a.id_material = m.id_material');

        qry.SQL.Add('WHERE a.id_vehicle = :id_vehicle');
        qry.SQL.Add('AND DATE(a.date) BETWEEN :data_inicio AND :data_fim');
        qry.SQL.Add('ORDER BY a.date');

        qry.ParamByName('id_vehicle').Value := id_vehicle;
        qry.ParamByName('data_inicio').Value := DataFirt;
        qry.ParamByName('data_fim').Value := DataLast;
        qry.Open;

        // Processa os resultados
        while not qry.Eof do
        begin


            // Adiciona o registro ao JSON array
            jsonObj := TJSONObject.Create;
            jsonObj.AddPair('date', FormatDateTime('yyyy-mm-dd"T"hh:nn:ss.zzz"Z"', qry.FieldByName('date').AsDateTime));
            jsonObj.AddPair('id_driver', qry.FieldByName('id_driver').AsString);
            jsonObj.AddPair('name', qry.FieldByName('name').AsString);
            jsonObj.AddPair('id_vehicle', qry.FieldByName('id_vehicle').AsString);
            jsonObj.AddPair('plate', qry.FieldByName('plate').AsString);
            jsonObj.AddPair('id_material', qry.FieldByName('id_material').AsString);
            jsonObj.AddPair('id_origin', qry.FieldByName('id_origin').AsString);
            jsonObj.AddPair('id_destination', qry.FieldByName('id_destination').AsString);
            jsonObj.AddPair('material', qry.FieldByName('material').AsString);
            jsonObj.AddPair('peso', qry.FieldByName('peso').AsString);
            jsonObj.AddPair('origin', qry.FieldByName('origin').AsString);
            jsonObj.AddPair('destination', qry.FieldByName('destination').AsString);

            jsonObj.AddPair('notafiscal', qry.FieldByName('notafiscal').AsString);
            jsonObj.AddPair('rate', TJSONNumber.Create(qry.FieldByName('rate').AsFloat));
            jsonObj.AddPair('rate_drive', TJSONNumber.Create(qry.FieldByName('rate_driver').AsFloat));
            jsonObj.AddPair('commission', TJSONNumber.Create(qry.FieldByName('commission').AsFloat));
            jsonObj.AddPair('value_liquido', TJSONNumber.Create(qry.FieldByName('value_liquido').AsFloat));
            jsonObj.AddPair('value_driver', TJSONNumber.Create(qry.FieldByName('value_driver').AsFloat));




            jsonArray.AddElement(jsonObj);
            qry.Next;
        end;

        // Adiciona o array e os totais ao objeto final
        finalJson.AddPair('trip', jsonArray);


        // Retorna o JSON final
        Result := finalJson;
    finally
        FreeAndNil(qry);
    end;
end;


///////CLIENTES
function TDtm.ListarClients(): TJsonArray;
var
    qry: TFDQuery;
begin
    try

        qry := TFDQuery.Create(nil);
        qry.Connection := Conn;

        qry.SQL.Add('SELECT * FROM tbl_client where excluded = :excluded');
        qry.ParamByName('excluded').Value := 'nao';
        qry.Open;

        Result := qry.ToJSONArray

    finally
        FreeAndNil(qry);
    end;
end;


function TDtm.InsertClient(name, cnpj, phone : string): TJsonObject;
var
    qry: TFDQuery;
begin
    try
    qry := TFDQuery.Create(nil);
    qry.Connection := Conn;


    // Verificar se o nome j� existe
    qry.SQL.Text := 'SELECT id_client FROM tbl_client WHERE cnpj = :cnpj and excluded = :excluded';
    qry.ParamByName('cnpj').Value := cnpj;
    qry.ParamByName('excluded').Value := 'nao';
    qry.Open;

    // Valida��o dos par�metros
    if not qry.IsEmpty then
    raise Exception.Create(' CNPJ j� usado.');

    if qry.IsEmpty then
    begin
      // Se n�o existir, insere o novo motorista
      qry.Close;
      qry.SQL.Clear;
      qry.SQL.Add('INSERT INTO tbl_client (name, cnpj, phone, excluded) VALUES (:name, :cnpj, :phone, :excluded)');
      qry.ParamByName('name').Value := name;
      qry.ParamByName('cnpj').Value := cnpj;
      qry.ParamByName('phone').Value := phone;
      qry.ParamByName('excluded').Value := 'nao';
      qry.ExecSQL;

      // Retorna o ID do novo motorista
      qry.SQL.Clear;
      qry.SQL.Add('SELECT * FROM tbl_client WHERE cnpj = :cnpj');
      qry.ParamByName('cnpj').Value := cnpj;
      qry.Open;
    end
    else
    begin
      // Se j� existir, retorna o motorista existente
      qry.Close;
      qry.SQL.Clear;
      qry.SQL.Add('SELECT * FROM tbl_client WHERE cnpj = :cnpj');
      qry.ParamByName('cnpj').Value := name;
      qry.Open;
    end;

    Result := qry.ToJsonObject;

  finally
    FreeAndNil(qry);
  end;
end;


function TDtm.UpdateClient(id_client: integer;  nameclient, cnpj, phone : string): TJsonObject;
var
    qry: TFDQuery;

begin
    try
        qry := TFDQuery.Create(nil);
        qry.Connection := Conn;

        // Valida��o dos par�metros
        if id_client <= 0 then
        raise Exception.Create('ID do Cliente inv�lido.');

        if Trim(name) = '' then
        raise Exception.Create('O nome do Cliente n�o pode estar vazio.');

        if Length(name) > 50 then
        raise Exception.Create('O nome do Cliente excede o limite de 50 caracteres.');

         // Verifica se o motorista existe antes de atualizar
        qry.SQL.Text := 'SELECT COUNT(*) FROM tbl_client WHERE id_client = :id_client';
        qry.ParamByName('id_client').AsInteger := id_client;
        qry.Open;

        if qry.Fields[0].AsInteger = 0 then
        raise Exception.Create('Cliente com o ID fornecido n�o existe.');

        with qry do
        begin

        // Limpa o SQL para a inser��o do novo registro
        qry.Close;
        qry.SQL.Clear;

        qry.SQL.Add('update tbl_client set name = :name, cnpj = :cnpj, phone = :phone');
        qry.SQL.Add('where id_client = :id_client');


         qry.ParamByName('name').Value := nameclient;
         qry.ParamByName('cnpj').Value := cnpj;
         qry.ParamByName('phone').Value := phone;
         qry.ParamByName('id_client').AsInteger := id_client;

        //qry.open;
        qry.ExecSQL;
        end;

        Result := qry.ToJsonObject;

          // Retorna um JSON com a resposta (se necess�rio)
          Result := TJsonObject.Create;
          Result.AddPair('status', 'success');
          Result.AddPair('message', 'Cliente atualizado com sucesso.');
          Result.AddPair('name', nameclient);
          Result.AddPair('id_client', TJSONNumber.Create(id_client));

    finally
        FreeAndNil(qry);
    end;
end;



function TDtm.DeleteClient(const id_client: integer): TJsonObject;
var
    qry: TFDQuery;
begin
   try
        qry := TFDQuery.Create(nil);
        qry.Connection := Conn;

        try
           Conn.StartTransaction;

           // Verifica se o registro existe antes de deletar
            qry.SQL.Add('SELECT id_client FROM tbl_client WHERE id_client = :id_client and excluded = :excluded');
            qry.ParamByName('id_client').Value := id_client;
            qry.ParamByName('excluded').Value := 'nao';
            qry.Open;

            if qry.IsEmpty then
            begin
                Conn.Rollback;
                raise Exception.Create('Registro n�o encontrado.');
            end;

           qry.Close;
           qry.SQL.Clear;
           qry.SQL.Add('DELETE FROM tbl_client where id_client = :id_client');
           qry.ParamByName('id_client').Value := id_client;
           qry.ExecSQL;

            Conn.Commit;
            Result := qry.ToJsonObject;
        except
            on ex: Exception do
            begin
                Conn.Rollback;
                raise Exception.Create(' Erro ao excluir o registro: ' + ex.Message);
            end;
        end;


    finally
        FreeAndNil(qry);
    end;
end;


///////RATES
function TDtm.ListarRates(): TJsonArray;
var
    qry: TFDQuery;
begin
    try

        qry := TFDQuery.Create(nil);
        qry.Connection := Conn;

        qry.SQL.Add('SELECT * FROM tbl_rates');
        qry.Open;

        Result := qry.ToJSONArray

    finally
        FreeAndNil(qry);
    end;
end;


function TDtm.ListarRateClient(id_client: integer): TJsonObject;
var
    qry: TFDQuery;
    jsonObject: TJsonObject;
    jsonArray: TJsonArray;
    field: TField;
begin
    try

        qry := TFDQuery.Create(nil);
        qry.Connection := Conn;

        qry.SQL.Add('SELECT id_rate, p1.name AS origem, p2.name AS destino, m.name AS material, rate, rate_driver FROM tbl_rates r');
        qry.SQL.Add('LEFT JOIN tbl_point p1 ON p1.id_point = r.id_origin');
        qry.SQL.Add('LEFT JOIN tbl_point p2 ON p2.id_point = r.id_destination');
        qry.SQL.Add('LEFT JOIN tbl_material m ON m.id_material = r.id_material');
        qry.SQL.Add('where r.id_client = :id_client');

        qry.ParamByName('id_client').Value := id_client;
        qry.Open;

        jsonArray := TJsonArray.Create;
    try
      while not qry.Eof do
      begin
        jsonObject := TJsonObject.Create;
        try
          // Adiciona todos os campos da consulta ao objeto JSON
          for field in qry.Fields do
          begin
            jsonObject.AddPair(field.FieldName, field.AsString);
          end;

          // Adiciona o objeto ao array
          jsonArray.AddElement(jsonObject);

          qry.Next;
        except
          jsonObject.Free;
          raise;
        end;
      end;

       // Cria o resultado final
      Result := TJsonObject.Create;
      Result.AddPair('data', jsonArray);
    except
      jsonArray.Free;
      raise;
    end;
  finally
    qry.Free;
  end;
end;


// Fun��o para inserir dados de Rates (Tarifas)
function TDtm.InsertRate(id_client, id_origin, id_destination, id_material: integer; rate, rate_driver : Currency): TJsonObject;
var
  qry: TFDQuery;
begin
  try
    qry := TFDQuery.Create(nil);
    qry.Connection := Conn;

    // Iniciar uma transa��o
    Conn.StartTransaction;

    // Inserir os dados na tabela tbl_trips
    qry.SQL.Text := 'INSERT INTO tbl_rates (id_client, id_origin, id_destination, id_material, rate, rate_driver) ' +
                    'VALUES (:id_client, :id_origin, :id_destination, :id_material, :rate, :rate_driver)';

    qry.ParamByName('id_client').Value := id_client;
    qry.ParamByName('id_origin').Value := id_origin;
    qry.ParamByName('id_destination').Value := id_destination;
    qry.ParamByName('id_material').Value := id_material;
    qry.ParamByName('rate').Value := rate;
    qry.ParamByName('rate_driver').Value := rate_driver;


    qry.ExecSQL;

    // Commit da transa��o
    Conn.Commit;

    // Retorna um JSON com o status de sucesso
    Result := TJsonObject.Create;
    Result.AddPair('status', 'success');
    Result.AddPair('message', 'Tarifa registrada com sucesso');
  except
    on E: Exception do
    begin
      // Caso ocorra um erro, faz o rollback e retorna a mensagem de erro
      Conn.Rollback;
      Result := TJsonObject.Create;
      Result.AddPair('status', 'error');
      Result.AddPair('message', 'Erro ao registrar viagem: ' + E.Message);
    end;
  end;
end;


function TDtm.UpdateRate(id_rate, id_client, id_origin, id_destination, id_material: integer; rate, rate_driver : Currency): TJsonObject;
var
    qry: TFDQuery;

begin
    try
        qry := TFDQuery.Create(nil);
        qry.Connection := Conn;

        // Valida��o dos par�metros
        if id_rate <= 0 then
        raise Exception.Create('ID da Tarifa inv�lido.');


         // Verifica se o motorista existe antes de atualizar
        qry.SQL.Text := 'SELECT COUNT(*) FROM tbl_rates WHERE id_rate = :id_rate';
        qry.ParamByName('id_rate').AsInteger := id_rate;
        qry.Open;

        if qry.Fields[0].AsInteger = 0 then
        raise Exception.Create('Tarifa com o ID fornecido n�o existe.');

        with qry do
        begin

        // Limpa o SQL para a inser��o do novo registro
        qry.Close;
        qry.SQL.Clear;

        qry.SQL.Add('update tbl_rates set id_client = :id_client, id_origin = :id_origin, id_destination = :id_destination, id_material = :id_material, rate = :rate, rate_driver = :rate_driver');
        qry.SQL.Add('where id_rate = :id_rate');


         qry.ParamByName('id_client').Value := id_client;
         qry.ParamByName('id_origin').Value := id_origin;
         qry.ParamByName('id_destination').Value := id_destination;
         qry.ParamByName('id_material').Value := id_material;
         qry.ParamByName('rate').Value := rate;
         qry.ParamByName('rate_driver').Value := rate_driver;
         qry.ParamByName('id_rate').AsInteger := id_rate;

        //qry.open;
        qry.ExecSQL;
        end;

        Result := qry.ToJsonObject;

          // Retorna um JSON com a resposta (se necess�rio)
          Result := TJsonObject.Create;
          Result.AddPair('status', 'success');
          Result.AddPair('message', 'Tarifa atualizado com sucesso.');
          Result.AddPair('id_rate', TJSONNumber.Create(id_rate));

    finally
        FreeAndNil(qry);
    end;
end;


function TDtm.DeleteRate(const id_rate: integer): TJsonObject;
var
    qry: TFDQuery;
begin
   try
        qry := TFDQuery.Create(nil);
        qry.Connection := Conn;

        try
           Conn.StartTransaction;

           // Verifica se o registro existe antes de deletar
            qry.SQL.Add('SELECT id_rate FROM tbl_rates WHERE id_rate = :id_rate');
            qry.ParamByName('id_rate').Value := id_rate;
            qry.Open;

            if qry.IsEmpty then
            begin
                Conn.Rollback;
                raise Exception.Create('Registro n�o encontrado.');
            end;

           qry.Close;
           qry.SQL.Clear;
           qry.SQL.Add('DELETE FROM tbl_rates where id_rate = :id_rate');
           qry.ParamByName('id_rate').Value := id_rate;
           qry.ExecSQL;

            Conn.Commit;
            Result := qry.ToJsonObject;
        except
            on ex: Exception do
            begin
                Conn.Rollback;
                raise Exception.Create(' Erro ao excluir o registro: ' + ex.Message);
            end;
        end;


    finally
        FreeAndNil(qry);
    end;
end;


end.
