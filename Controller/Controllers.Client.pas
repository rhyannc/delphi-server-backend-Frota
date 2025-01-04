unit Controllers.Client;

interface

uses Horse,
     System.JSON,
     System.SysUtils,
     DM;

     procedure RegistrarRotas;
     procedure ListarClients(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
     procedure InsertClient(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
     procedure UpdateClient(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
     procedure DeleteClient(Req: THorseRequest; Res: THorseResponse; Next: Tproc);

implementation

procedure RegistrarRotas;
begin
    // Configurações de endpoints do Horse
    THorse.Get('/listarclients',  ListarClients);
    THorse.Post('/postclient',  InsertClient);
    THorse.Put('/updateclient', UpdateClient);
    THorse.Delete('/deleteclient/:id_client',  DeleteClient);

end;


procedure ListarClients(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
var
  dm:TDtm;
begin
      try
          dm  := TDtm.Create(nil);
          Res.Send(dm.ListarClients()).Status(200);
      finally
          FreeAndNil(dm);
      end;
end;

procedure InsertClient(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
var
  dm:TDtm;
  body: TJSONObject;
  name, cnpj, phone: string;
begin
      try
        try
            dm          := TDtm.Create(nil);
            body        := Req.Body<TJSONObject>;

            name      := body.GetValue<string>('name', '');
            cnpj      := body.GetValue<string>('cnpj', '');
            phone      := body.GetValue<string>('phone', '');

            Res.Send(dm.InsertClient(name, cnpj, phone)).Status(201);

        except
          on ex:exception do
            Res.Send('Houve  um erro:' + ex.Message).Status(502);     //DEU ERRO
        end;
      finally
          FreeAndNil(dm);
      end;
end;

// Função para Atualizar um registro específico
procedure UpdateClient(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
var
  dm:TDtm;
  body, Json_ret: TJSONObject;
  name, cnpj, phone: string;
  id_client: integer;
begin
     try
        try
            dm       := TDtm.Create(nil);

            body     := Req.Body<TJSONObject>;
            id_client := body.GetValue<integer>('id_client', 0);
            name      := body.GetValue<string>('name', '');
            cnpj      := body.GetValue<string>('cnpj', '');
            phone      := body.GetValue<string>('phone', '');

            Json_ret := dm.UpdateClient(id_client, name, cnpj, phone);
            Res.Send<TJsonObject>(Json_ret).Status(201);

        except
          on ex:exception do
            Res.Send('Ops! ' + ex.Message).Status(502);     //DEU ERRO
        end;
      finally
          FreeAndNil(dm);
      end;
end;

// Função para deletar um registro específico
procedure DeleteClient(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
var
  dm:TDtm;
  id_client: integer;
  Json_ret: TJSONObject;
begin
     try
        try
            dm       := TDtm.Create(nil);

            try
               id_client  := Req.Params.Items['id_client'].ToInteger;
            except
               id_client := 0;
            end;

            Json_ret := dm.DeleteClient(id_client);


            Res.Send('Cliente Id  ' + inttostr(id_client) + '  Foi Excluido!').Status(200);

        except
          on ex:exception do
            Res.Send('Ops! ' + ex.Message).Status(404);     //DEU ERRO
        end;
      finally
          FreeAndNil(dm);
      end;
end;

end.
