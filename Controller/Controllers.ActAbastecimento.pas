unit Controllers.ActAbastecimento;

interface

uses Horse,
     System.JSON,
     System.SysUtils,
     DM;

     procedure RegistrarRotas;
     procedure InsertAbastecimento(Req: THorseRequest; Res: THorseResponse; Next: Tproc);

implementation

procedure RegistrarRotas;
begin
    // Configurações de endpoints do Horse
    THorse.Post('/postabastecimento',  InsertAbastecimento);

end;

procedure InsertAbastecimento(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
var
  dm:TDtm;
  body: TJSONObject;
  local, km_vehicle: string;
  id_driver, id_vehicle: integer;
  value, value_l_fuel, litros_fuel: Currency;
begin
      try
        try
            dm          := TDtm.Create(nil);
            body        := Req.Body<TJSONObject>;

            id_driver    := body.GetValue<integer>('id_driver', 0);
            id_vehicle   := body.GetValue<integer>('id_vehicle', 0);
            value        := body.GetValue<Currency>('value', 0);

            km_vehicle          := body.GetValue<string>('km_vehicle', '');
            value_l_fuel        := body.GetValue<Currency>('value_l_fuel', 0);
            litros_fuel         := body.GetValue<Currency>('litros_fuel', 0);
            local               := body.GetValue<string>('local', '');

            // Chama a função para inserir a viagem (ou trip), passando os dados
            Res.Send(dm.InsertActAbastecimento(id_driver, id_vehicle, value_l_fuel, litros_fuel, value, local, km_vehicle)).Status(201);

        except
          on ex:exception do
            Res.Send('Houve  um erro:' + ex.Message).Status(502);     //DEU ERRO
        end;
      finally
          FreeAndNil(dm);
      end;
end;

end.
