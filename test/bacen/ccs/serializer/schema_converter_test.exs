defmodule Bacen.CCS.Serializer.SchemaConverterTest do
  use Bacen.CCS.EctoCase
  doctest Bacen.CCS.Serializer.SchemaConverter

  alias Bacen.CCS.Serializer.SchemaConverter

  describe "to_xml/2" do
    test "converts ACCS001 into XML tuple-formatted" do
      accs001 =
        build(:accs001,
          daily_update:
            build(:daily_update,
              persons:
                build(:accs001_persons,
                  cnpj: "65490167",
                  person: build_list(1, :accs001_person, cpf_cnpj: "96709797228")
                )
            )
        )

      message =
        build(:message,
          message:
            build(:base_message,
              body: accs001,
              header: build(:header, issuer_id: "69930846", recipient_id: "25992990")
            )
        )

      assert SchemaConverter.to_xml(message, 'foo') ===
               {:ok,
                {:CCSDOC, [xmlns: 'foo'],
                 [
                   BCARQ: [
                     IdentdEmissor: ['69930846'],
                     IdentdDestinatario: ['25992990'],
                     NomArq: ['ACCS001'],
                     NumRemessaArq: ['000000000000']
                   ],
                   SISARQ: [
                     CCSArqAtlzDiaria: [
                       Repet_ACCS001_Pessoa: [
                         CNPJBasePart: ['65490167'],
                         Grupo_ACCS001_Pessoa: [
                           [
                             TpPessoa: ['F'],
                             TpOpCCS: ['I'],
                             QualifdrOpCCS: ['C'],
                             DtIni: ['2021-05-07'],
                             CNPJ_CPFPessoa: ['96709797228']
                           ]
                         ]
                       ],
                       QtdOpCCS: '1',
                       DtMovto: ['2021-05-07']
                     ]
                   ]
                 ]}}
    end

    test "converts ACCS003 into XML tuple-formatted" do
      accs003 =
        build(:accs003,
          daily_update_validation:
            build(:daily_update_validation,
              persons:
                build(:accs003_persons,
                  cnpj: "36935289",
                  person: build_list(1, :accs003_person, cpf_cnpj: "96709797228")
                )
            )
        )

      message =
        build(:message,
          message:
            build(:base_message,
              body: accs003,
              header:
                build(:header,
                  issuer_id: "69930846",
                  recipient_id: "25992990",
                  file_name: "ACCS003"
                )
            )
        )

      assert SchemaConverter.to_xml(message, 'foo') ===
               {:ok,
                {:CCSDOC, [xmlns: 'foo'],
                 [
                   BCARQ: [
                     IdentdEmissor: ['69930846'],
                     IdentdDestinatario: ['25992990'],
                     NomArq: ['ACCS003'],
                     NumRemessaArq: ['000000000000']
                   ],
                   SISARQ: [
                     CCSArqValidcAtlzDiaria: [
                       Repet_ACCS003_Pessoa: [
                         CNPJBasePart: ['36935289'],
                         Grupo_ACCS003_Pessoa: [
                           [
                             TpPessoa: ['F'],
                             TpOpCCS: ['I'],
                             QualifdrOpCCS: ['C'],
                             DtIni: ['2021-05-07'],
                             CNPJ_CPFPessoa: ['96709797228']
                           ]
                         ]
                       ],
                       QtdErro: '0',
                       QtdOpCCSActo: '1',
                       DtHrBC: ['2021-05-07 05:04:00Z'],
                       DtMovto: ['2021-05-07']
                     ]
                   ]
                 ]}}
    end

    test "converts ACCS004 into XML tuple-formatted" do
      accs004 =
        build(:accs004,
          registration_position:
            build(:registration_position,
              conglomerate:
                build(:conglomerate, participant: build_list(1, :participant, cnpj: "44843979")),
              persons:
                build(:accs004_persons,
                  cnpj: "36935289",
                  person: build_list(1, :accs004_person, cpf_cnpj: "96709797228")
                )
            )
        )

      message =
        build(:message,
          message:
            build(:base_message,
              body: accs004,
              header:
                build(:header,
                  issuer_id: "69930846",
                  recipient_id: "25992990",
                  file_name: "ACCS004"
                )
            )
        )

      assert SchemaConverter.to_xml(message, 'foo') ===
               {:ok,
                {:CCSDOC, [xmlns: 'foo'],
                 [
                   BCARQ: [
                     IdentdEmissor: ['69930846'],
                     IdentdDestinatario: ['25992990'],
                     NomArq: ['ACCS004'],
                     NumRemessaArq: ['000000000000']
                   ],
                   SISARQ: [
                     CCSArqPosCad: [
                       Repet_ACCS004_Congl: [[CNPJBasePart: ['44843979']]],
                       Repet_ACCS004_Pessoa: [
                         CNPJBasePart: ['36935289'],
                         Grupo_ACCS004_Pessoa: [
                           [
                             TpPessoa: ['F'],
                             DtIni: ['2021-05-07'],
                             CNPJ_CPFPessoa: ['96709797228']
                           ]
                         ]
                       ],
                       DtMovto: ['2021-05-07']
                     ]
                   ]
                 ]}}
    end
  end
end
