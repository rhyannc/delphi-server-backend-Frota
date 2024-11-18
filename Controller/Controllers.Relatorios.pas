unit Controllers.Relatorios;

interface

uses Horse,
     System.JSON,
     System.SysUtils,
     DM;

     procedure RegistrarRotas;
     procedure ReportAbastecimento(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
     procedure ReportService(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
     procedure ReportTrip(Req: THorseRequest; Res: THorseResponse; Next: Tproc);

implementation

procedure RegistrarRotas;
begin
    // Configurações de endpoints do Horse
    THorse.Post('/reportabastecimento',  ReportAbastecimento);
    THorse.Post('/reportservice',  ReportService);
    THorse.Post('/reporttrip',  ReportTrip);

end;

procedure ReportAbastecimento(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
var
  dm:TDtm;
  body: TJSONObject;
  dt1, dt2: string;
  firstdate, lastdate: TDateTime;
  id_vehicle: integer;
begin
      try
        try
            dm          := TDtm.Create(nil);
            body        := Req.Body<TJSONObject>;

            id_vehicle   := body.GetValue<integer>('id_vehicle', 0);
            dt1 := body.GetValue<string>('firstdt', '');
            dt2 := body.GetValue<string>('lastdt', '');

            firstdate       := StrToDate(dt1) ;
            lastdate        := StrToDate(dt2) ;


            // Chama a função para inserir a viagem (ou trip), passando os dados
            Res.Send(dm.ReportAbastecimento(id_vehicle, firstdate, lastdate)).Status(201);

        except
          on ex:exception do
            Res.Send('Houve  um erro:' + ex.Message).Status(502);     //DEU ERRO
        end;
      finally
          FreeAndNil(dm);
      end;
end;

procedure ReportService(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
var
  dm:TDtm;
  body: TJSONObject;
  dt1, dt2: string;
  firstdate, lastdate: TDateTime;
  id_vehicle: integer;
begin
      try
        try
            dm          := TDtm.Create(nil);
            body        := Req.Body<TJSONObject>;

            id_vehicle   := body.GetValue<integer>('id_vehicle', 0);
            dt1 := body.GetValue<string>('firstdt', '');
            dt2 := body.GetValue<string>('lastdt', '');

            firstdate       := StrToDate(dt1) ;
            lastdate        := StrToDate(dt2) ;


            // Chama a função para inserir a viagem (ou trip), passando os dados
            Res.Send(dm.ReportService(id_vehicle, firstdate, lastdate)).Status(201);

        except
          on ex:exception do
            Res.Send('Houve  um erro:' + ex.Message).Status(502);     //DEU ERRO
        end;
      finally
          FreeAndNil(dm);
      end;
end;

procedure ReportTrip(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
var
  dm:TDtm;
  body: TJSONObject;
  dt1, dt2: string;
  firstdate, lastdate: TDateTime;
  id_vehicle: integer;
begin
      try
        try
            dm          := TDtm.Create(nil);
            body        := Req.Body<TJSONObject>;

            id_vehicle   := body.GetValue<integer>('id_vehicle', 0);
            dt1 := body.GetValue<string>('firstdt', '');
            dt2 := body.GetValue<string>('lastdt', '');

            firstdate       := StrToDate(dt1) ;
            lastdate        := StrToDate(dt2) ;


            // Chama a função para inserir a viagem (ou trip), passando os dados
            Res.Send(dm.ReportTrip(id_vehicle, firstdate, lastdate)).Status(201);

        except
          on ex:exception do
            Res.Send('Houve  um erro:' + ex.Message).Status(502);     //DEU ERRO
        end;
      finally
          FreeAndNil(dm);
      end;
end;

end.
