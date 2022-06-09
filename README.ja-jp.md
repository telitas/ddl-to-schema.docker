# ddl-to-schema.docker

ddl-to-schema.dockerは、RDBのDDLからテキストデータスキーマを生成します。

## README Language

- [English](./README.md)
- [Japanese(日本語)](./README.ja-jp.md)

## Usage

まず[EXTRACT_SCHEMA.PSM-postgresql](https://github.com/telitas/EXTRACT_SCHEMA.PSM-postgresql) の最新のリリースをダウンロードし、extract_table_as_*.sqlファイルを"bundle"ディレクトリに移動します。

続いてCREATE TABLE DDLを作成し(PostgreSQLの構文で記述する必要があります)、.sqlファイルとして"ddl"ディレクトリに保存します。

```sql
-- example
CREATE TABLE example (
    id NUMERIC(8) PRIMARY KEY,
    name CHARACTER VARYING(20)
);
```

そして、スクリプトを実行します。

```sh
# in bash
./generate.sh xml
```

```ps1
# in PowerShell
./ConvertTo-Document.ps1 json
```

最後に、以下のスキーマファイルが"dest”ディレクトリに出力されます。

```xml
<!-- example -->
<?xml version="1.0"?>
<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
  <xs:element name="rows" type="Rows">
    <xs:key name="example_pkey">
      <xs:selector xpath="row"/>
      <xs:field xpath="id"/>
    </xs:key>
  </xs:element>
  <xs:complexType name="Rows">
    <xs:sequence>
      <xs:element name="row" type="Row" minOccurs="0" maxOccurs="unbounded"/>
    </xs:sequence>
  </xs:complexType>
  <xs:complexType name="Row">
    <xs:sequence>
      <xs:element name="id">
        <xs:simpleType>
          <xs:restriction base="xs:decimal">
            <xs:totalDigits value="8"/>
            <xs:fractionDigits value="0"/>
          </xs:restriction>
        </xs:simpleType>
      </xs:element>
      <xs:element name="name" nillable="true" minOccurs="0">
        <xs:simpleType>
          <xs:restriction base="xs:string">
            <xs:maxLength value="20"/>
          </xs:restriction>
        </xs:simpleType>
      </xs:element>
    </xs:sequence>
  </xs:complexType>
</xs:schema>
```

```json
// example
{
  "$schema": "https://json-schema.org/draft/2019-09/schema#",
  "$id": "https://telitas.dev/extract_schema.psm/public/example/schema#",
  "type": "array",
  "items": {
    "$ref": "#/definitions/row"
  },
  "definitions": {
    "row": {
      "type": "object",
      "additionalProperties": false,
      "properties": {
        "id": {
          "type": "string",
          "pattern": "^-?(?:0*[0-9]{1,8}(?:\\.0*)?|\\.0+)$"
        },
        "name": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 20
        }
      },
      "required": [
        "id"
      ]
    }
  }
}
```

## License

MIT

Copyright (c) 2022 telitas

See the LICENSE file or https://opensource.org/licenses/mit-license.php for details.
