<?php
// ini_set("display_errors", 1);
// error_reporting(E_ALL);
// mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);
//------------------- schema -----------------------------
/*
    CREATE TABLE `persona` (
      `id` int(11) NOT NULL,
      `nome` varchar(64) NOT NULL,
      `cognome` varchar(64) NOT NULL,
      `mail` varchar(255) DEFAULT NULL
    )

    CREATE TABLE `sede` (
      `id` int(11) NOT NULL,
      `nome` varchar(64) NOT NULL,
      `indirizzo` varchar(255) NOT NULL
    )

    CREATE TABLE `tessera` (
      `id` int(11) NOT NULL,
      `sede_creazione_id` int(11) NOT NULL,
      `punti` int(11) NOT NULL,
      `cliente_id` int(11) NOT NULL,
      `data_creazione` datetime NOT NULL DEFAULT current_timestamp()
    )
*/
//END ------------------- schema -----------------------------

//------------------- DOCS ----------------------------------
/*
    WEB SERVICE MULTI-OPERAZIONE CON NOME DELL'OPERAZIONE IN URL
    richiesta http://localhost/scientology_market/smapi.php/operazione?querystring

    OPERAZIONI:
    -read (metodo: GET) (tipo: read) (parametro: content) (risposta: JSON(default) | XML)
        -se response=json (default)
            restituisce la risposta in json
        -se response=xml
            restituisce la risposta in xml
        -se content=clienti
            restituisce l'elenco dei clienti registrati e che quindi ad un certo punto hanno richiesto una tessera
        -se content=sedi
            restituisce l'elenco delle sedi
        -se content=tessere
            restituisce l'elenco di tutte le tessere
        -se content=popolarita_sedi
            restituisce l'elenco delle sedi con il numero totale di tessere mai create in tale sede ed il totale di tessere create per ogni mese se ce ne sono state
    -PATCH | PUT:
        es di formattazione richiesta in json:
            HEADERS:
                [...]
                Content-Type: application/json

            BODY:
                {
                    "tessera": {            //nome tabella dell'elemento da modificare
                        "id": 11,           //id della riga da modificare
                        "punti": 1223       //campi da modificare con nuovo valore
                    },
                    "persona":{             //secondo elemento da modificare
                        "id": 1,
                        "nome":"Antonio"
                    }
                    // ...  il numero degli elementi da modificare può andare da 0 a N
                }

        es in XML
            HEADERS:
                [...]
                Content-Type: application/xml
            BODY:
            <root>                              //elemento radice che funge da contenitore (può essere qualsiasi cosa)
                <persona>                       //nome tabella dell'elemento da modificare
                    <id>2</id>                  //id della riga da modificare
                    <nome>tutu</nome>           //campi da modificare con nuovo valore
                    <cognome>Verdi</cognome>
                </persona>
                <tessera>                       //secondo elemento da modificare
                    <id>2</id>
                    <punti>33</punti>
                </tessera>
                // ...  il numero degli elementi da modificare può andare da 0 a N
            </root>
*/
//END ------------------- DOCS -----------------------------

//----------------------------------- INIT VAR ------------------------------------------

cors();

$statuscode = 405; //status code inizializzato a 405 Method Not Allowed

$uri_arr = parse_url($_SERVER["REQUEST_URI"]); //scompone l'uri in parti (vedi manuale)
$temp = explode("/", $uri_arr["path"]);
$op = end($temp); //estrae l'ultima parte dell'uri (dopo l'ultimo /) quindi l'ultima operazione richiesta

$response_type = "json";
if (isset($_REQUEST["response"])) {
    switch ($_REQUEST["response"]) {
        case "json":
            $response_type = "json";
            break;
        case "xml":
            $response_type = "xml";
            break;
        default:
            $response_type = "json";
            break;
    }
}

// header per indicare al browser che la risposta saranno dati in json/xml
header("Content-Type: application/$response_type");

$conn = new mysqli("localhost", "root", "", "scientology_market");

//END ----------------------------------- INIT VAR ------------------------------------------

function cors()
{
    // Allow from any origin
    if (isset($_SERVER["HTTP_ORIGIN"])) {
        // Decide if the origin in $_SERVER['HTTP_ORIGIN'] is one
        // you want to allow, and if so:
        header("Access-Control-Allow-Origin: {$_SERVER["HTTP_ORIGIN"]}");
        header("Access-Control-Allow-Credentials: true");
        header("Access-Control-Max-Age: 86400"); // cache for 1 day
    }

    // Access-Control headers are received during OPTIONS requests
    if ($_SERVER["REQUEST_METHOD"] == "OPTIONS") {
        if (isset($_SERVER["HTTP_ACCESS_CONTROL_REQUEST_METHOD"])) {
            // may also be using PUT, PATCH, HEAD etc
            header(
                "Access-Control-Allow-Methods: GET, POST, PUT, PATCH, DELETE, OPTIONS"
            );
        }

        if (isset($_SERVER["HTTP_ACCESS_CONTROL_REQUEST_HEADERS"])) {
            header(
                "Access-Control-Allow-Headers: {$_SERVER["HTTP_ACCESS_CONTROL_REQUEST_HEADERS"]}"
            );
        }

        exit(0);
    }
}

if ($_SERVER["REQUEST_METHOD"] == "GET") {
    //switch per gestire le varie operazioni
    switch ($op) {
        case "read":
            //controllo se il parametro è adeguato per eseguire l'operazione
            if (isset($_GET["content"]) && !empty($_GET["content"])) {
                //switch per gestire la richiesta read in base al parametro content
                switch ($_GET["content"]) {
                    case "clienti":
                        $sql = "SELECT * FROM persona"; //query per estrarre tutti i clienti
                        $stmt = $conn->prepare($sql);
                        $stmt->execute();
                        $res = $stmt->get_result();

                        if ($res->num_rows == 0) {
                            $statuscode = 204; //l'operazione non ha estratto dati
                        } else {
                            $statuscode = 200; //l'operazione ha avuto successo
                        }

                        if ($response_type == "xml") {
                            // elemento radice (attenzione: va scritto come se fosse un XML completo)
                            $xml = new SimpleXMLElement("<clienti_tesserati/>");
                            for ($i = 0; $i < $res->num_rows; $i++) {
                                $record = $res->fetch_assoc();

                                // aggiunta di un elemento figlio alla radice
                                $child = $xml->addChild("cliente");

                                // aggiunta di attributi ed elementi all'elemento figlio
                                $child->addAttribute("id", $record["id"]);
                                $child->addChild("nome", $record["nome"]);
                                $child->addChild("cognome", $record["cognome"]);
                                $child->addChild("mail", $record["mail"]);
                            }
                            // invio risposta XML al client
                            echo $xml->asXML();
                        } else {
                            //JSON
                            $json = new stdClass();
                            //elemento radice
                            $json->clienti_tesserati = [];

                            for ($i = 0; $i < $res->num_rows; $i++) {
                                $record = $res->fetch_assoc();

                                //singolo elemento con i suoi attributi
                                $json->clienti_tesserati[$i] = (object) [
                                    "id" => $record["id"],
                                    "nome" => $record["nome"],
                                    "cognome" => $record["cognome"],
                                    "mail" => $record["mail"],
                                ];
                            }
                            echo json_encode($json);
                        }

                        $res->free();
                        break;

                    case "sedi":
                        $sql = "SELECT * FROM sede"; //query per estrarre tutte le sedi
                        $conditions = [];
                        $params = [];
                        $stmt_type = "";

                        //primo filro che implementa il nome che controlla se c'è e in caso aggiunta un filto
                        if (isset($_GET["nome"]) && $_GET["nome"] != "") {
                            $conditions[] = "nome LIKE ?";
                            $stmt_type .= "s";
                            $params[] = "%" . $_GET["nome"] . "%";
                        }
                        if (
                            isset($_GET["indirizzo"]) &&
                            $_GET["indirizzo"] != ""
                        ) {
                            $conditions[] = "indirizzo LIKE ?";
                            $stmt_type .= "s";
                            $params[] = "%" . $_GET["indirizzo"] . "%";
                        }
                        if (count($conditions) > 0) {
                            $sql .= " WHERE " . implode(" AND ", $conditions);
                            $stmt = $conn->prepare($sql);
                            $stmt->bind_param($stmt_type, ...$params);
                        } else {
                            $stmt = $conn->prepare($sql);
                        }

                        $stmt->execute();
                        $res = $stmt->get_result();

                        if ($res->num_rows == 0) {
                            $statuscode = 204; //l'operazione non ha estratto dati
                        } else {
                            $statuscode = 200; //l'operazione ha avuto successo
                        }

                        if ($response_type == "xml") {
                            // elemento radice (attenzione: va scritto come se fosse un XML completo)
                            $xml = new SimpleXMLElement("<sedi/>");
                            for ($i = 0; $i < $res->num_rows; $i++) {
                                $record = $res->fetch_assoc();

                                // aggiunta di un elemento figlio alla radice
                                $child = $xml->addChild("sede");

                                $child->addAttribute("id", $record["id"]);
                                // aggiunta di attributi ed elementi all'elemento figlio
                                $child->addChild("nome", $record["nome"]);
                                $child->addChild(
                                    "indirizzo",
                                    $record["indirizzo"]
                                );
                            }
                            // invio risposta XML al client
                            echo $xml->asXML();
                        } else {
                            //JSON
                            $json = new stdClass();
                            //elemento radice
                            $json->sedi = [];

                            for ($i = 0; $i < $res->num_rows; $i++) {
                                $record = $res->fetch_assoc();

                                //singolo elemento con i suoi attributi
                                $json->sedi[$i] = (object) [
                                    "id" => $record["id"],
                                    "nome" => $record["nome"],
                                    "indirizzo" => $record["indirizzo"],
                                ];
                            }
                            echo json_encode($json);
                        }

                        $res->free();

                        break;

                    case "tessere":
                        //query per estrarre tutte le tessere create con i relativi dati della sede di creazione e del clientes
                        $sql =
                            "SELECT tessera.id, tessera.punti, tessera.data_creazione, CONCAT(sede.nome, ', ', sede.indirizzo) AS sede_di_creazione , persona.id AS cId, persona.nome AS cNome, persona.cognome AS cCognome, persona.mail AS cEmail FROM `tessera` JOIN sede ON sede.id=tessera.sede_creazione_id JOIN persona ON persona.id=tessera.cliente_id ORDER BY tessera.id";
                        $conditions = [];
                        $stmt_type = "";
                        $params = [];

                        //primo filro che implementa il nome che controlla se c'è e in caso aggiunta un filto
                        if (isset($_GET["nome"]) && $_GET["nome"] != "") {
                            $conditions[] = "persona.nome LIKE ?";
                            $stmt_type .= "s";
                            $params[] = "%" . $_GET["nome"] . "%";
                        }
                        if (isset($_GET["cognome"]) && $_GET["cognome"] != "") {
                            $conditions[] = "persona.cognome LIKE ?";
                            $stmt_type .= "s";
                            $params[] = "%" . $_GET["cognome"] . "%";
                        }
                        if (count($conditions) > 0) {
                            $sql .= " WHERE " . implode(" AND ", $conditions);
                            $stmt = $conn->prepare($sql);
                            $stmt->bind_param($stmt_type, ...$params);
                        } else {
                            $stmt = $conn->prepare($sql);
                        }
                        $stmt->execute();
                        $res = $stmt->get_result();
                        if ($res->num_rows == 0) {
                            $statuscode = 204; //l'operazione non ha estratto dati
                        } else {
                            $statuscode = 200; //l'operazione ha avuto successo
                        }

                        if ($response_type == "xml") {
                            // elemento radice (attenzione: va scritto come se fosse un XML completo)
                            $xml = new SimpleXMLElement("<tessere/>");
                            for ($i = 0; $i < $res->num_rows; $i++) {
                                $record = $res->fetch_assoc();

                                // aggiunta di un elemento figlio alla radice
                                $child = $xml->addChild("tessera");

                                // aggiunta di attributi ed elementi all'elemento figlio
                                $child->addAttribute(
                                    "numero_tessera",
                                    $record["id"]
                                );
                                $child->addChild("punti", $record["punti"]);
                                $child->addChild(
                                    "data_di_creazione",
                                    $record["data_creazione"]
                                );
                                $child->addChild(
                                    "sede_di_creazione",
                                    $record["sede_di_creazione"]
                                );
                                $clientechild = $child->addChild("cliente");
                                $clientechild->addAttribute(
                                    "id",
                                    $record["cId"]
                                );
                                $clientechild->addChild(
                                    "nome",
                                    $record["cNome"]
                                );
                                $clientechild->addChild(
                                    "cognome",
                                    $record["cCognome"]
                                );
                                $clientechild->addChild(
                                    "mail",
                                    $record["cEmail"]
                                );
                            }
                            echo $xml->asXML();
                        } else {
                            //JSON
                            $json = new stdClass();
                            //elemento radice
                            $json->tessere = [];

                            for ($i = 0; $i < $res->num_rows; $i++) {
                                $record = $res->fetch_assoc();

                                //singolo elemento con i suoi attributi
                                $json->tessere[$i] = (object) [
                                    "numero_tessera" => $record["id"],
                                    "punti" => $record["punti"],
                                    "data_di_creazione" =>
                                        $record["data_creazione"],
                                    "sede_di_creazione" =>
                                        $record["sede_di_creazione"],
                                    "cliente" => (object) [
                                        "id" => $record["cId"],
                                        "nome" => $record["cNome"],
                                        "cognome" => $record["cCognome"],
                                        "mail" => $record["cEmail"],
                                    ],
                                ];
                            }
                            echo json_encode($json);
                        }

                        $res->free();

                        break;

                    case "popolarita_sedi":
                        //query per estrarre il totale delle tessere create con la sede di creazione comprendendo anche le sedi che non ne hanno create
                        $sql =
                            "SELECT COUNT(tessera.id) AS 'n_tessere_create', sede.nome, sede.indirizzo, sede.id FROM sede LEFT JOIN tessera ON tessera.sede_creazione_id=sede.id ";
                        $conditions = [];
                        $params = [];
                        $stmt_type = "";

                        //primo filro che implementa il nome che controlla se c'è e in caso aggiunta un filto
                        if (isset($_GET["nome"]) && $_GET["nome"] != "") {
                            $conditions[] = " nome LIKE ? ";
                            $stmt_type .= "s";
                            $params[] = "%" . $_GET["nome"] . "%";
                        }
                        if (
                            isset($_GET["indirizzo"]) &&
                            $_GET["indirizzo"] != ""
                        ) {
                            $conditions[] = " indirizzo LIKE ? ";
                            $stmt_type .= "s";
                            $params[] = "%" . $_GET["indirizzo"] . "%";
                        }
                        if (
                            isset($_GET["end_date"]) &&
                            $_GET["end_date"] != ""
                        ) {
                            $date = date_create(
                                $_GET["end_date"] . "-1 23:59:59"
                            );
                            $data = date_format($date, "Y-m-t H:i:s");
                            $conditions[] = " tessera.data_creazione < ? ";
                            $stmt_type .= "s";
                            $params[] = $data;
                        }
                        if (
                            isset($_GET["start_date"]) &&
                            $_GET["start_date"] != ""
                        ) {
                            $date = date_create(
                                $_GET["start_date"] . "-1 00:00:00"
                            );
                            $data = date_format($date, "Y-m-d H:i:s");
                            $conditions[] = " tessera.data_creazione > ? ";
                            $stmt_type .= "s";
                            $params[] = $data;
                        }
                        if (count($conditions) > 0) {
                            $sql .= " WHERE " . implode(" AND ", $conditions);
                            $sql .=
                                " GROUP BY sede.id ORDER BY tessera.sede_creazione_id; ";
                            $stmt = $conn->prepare($sql);
                            $stmt->bind_param($stmt_type, ...$params);
                        } else {
                            $sql .=
                                " GROUP BY sede.id ORDER BY tessera.sede_creazione_id; ";
                            $stmt = $conn->prepare($sql);
                        }
                        $stmt->execute();
                        $res = $stmt->get_result();

                        if ($res->num_rows == 0) {
                            $statuscode = 204; //l'operazione non ha estratto dati
                        } else {
                            $statuscode = 200; //l'operazione ha avuto successo
                        }

                        if ($response_type == "xml") {
                            // elemento radice (attenzione: va scritto come se fosse un XML completo)
                            $xml = new SimpleXMLElement("<sedi/>");
                            for ($i = 0; $i < $res->num_rows; $i++) {
                                $record = $res->fetch_assoc();

                                // aggiunta di un elemento figlio alla radice
                                $child = $xml->addChild("sede");

                                // aggiunta di attributi ed elementi all'elemento figlio
                                $child->addAttribute("nome", $record["nome"]);
                                $child->addAttribute(
                                    "indirizzo",
                                    $record["indirizzo"]
                                );
                                $child->addAttribute(
                                    "n_tot_di_tessere_create",
                                    $record["n_tessere_create"]
                                );

                                //query per estrarre il totale delle tessere diviso per mese
                                $sql =
                                    "SELECT DATE_FORMAT(tessera.data_creazione ,'%M %Y') as mese, COUNT(tessera.id) AS ntessere FROM tessera JOIN sede ON sede.id=tessera.sede_creazione_id WHERE tessera.sede_creazione_id=? ";
                                if (count($conditions) > 0) {
                                    $sql .=
                                        " AND " . implode(" AND ", $conditions);
                                }
                                $sql .=
                                    " GROUP BY YEAR(tessera.data_creazione), MONTH(tessera.data_creazione) ORDER BY YEAR(tessera.data_creazione), MONTH(tessera.data_creazione); ";

                                $stmt = $conn->prepare($sql);
                                $stmt->bind_param(
                                    "i" . $stmt_type,
                                    $record["id"],
                                    ...$params
                                );
                                $stmt->execute();
                                $childres = $stmt->get_result();

                                //aggiunta dei mesi in cui sono state create delle tessere con il relativo totale
                                for ($j = 0; $j < $childres->num_rows; $j++) {
                                    $childrecord = $childres->fetch_assoc();
                                    $sedechild = $child->addChild("periodo");
                                    $sedechild->addAttribute(
                                        "mese",
                                        $childrecord["mese"]
                                    );
                                    $sedechild->addAttribute(
                                        "n_tessere_create",
                                        $childrecord["ntessere"]
                                    );
                                }
                                $childres->free();
                            }
                            echo $xml->asXML();
                        } else {
                            //JSON
                            $json = new stdClass();
                            //elemento radice
                            $json->sedi = [];

                            for ($i = 0; $i < $res->num_rows; $i++) {
                                $record = $res->fetch_assoc();

                                //singolo elemento con i suoi attributi
                                $json->sedi[$i] = (object) [
                                    "nome" => $record["nome"],
                                    "indirizzo" => $record["indirizzo"],
                                    "n_tot_di_tessere_create" =>
                                        $record["n_tessere_create"],
                                ];

                                //query per estrarre il totale delle tessere diviso per mese
                                $sql =
                                    "SELECT DATE_FORMAT(tessera.data_creazione ,'%M %Y') as mese, COUNT(tessera.id) AS ntessere FROM tessera JOIN sede ON sede.id=tessera.sede_creazione_id WHERE tessera.sede_creazione_id=? ";
                                if (count($conditions) > 0) {
                                    $sql .=
                                        " AND " . implode(" AND ", $conditions);
                                }
                                $sql .=
                                    " GROUP BY YEAR(tessera.data_creazione), MONTH(tessera.data_creazione) ORDER BY YEAR(tessera.data_creazione), MONTH(tessera.data_creazione); ";

                                $stmt = $conn->prepare($sql);
                                $stmt->bind_param(
                                    "i" . $stmt_type,
                                    $record["id"],
                                    ...$params
                                );
                                $stmt->execute();
                                $childres = $stmt->get_result();

                                //aggiunta dei mesi in cui sono state create delle tessere con il relativo totale
                                for ($j = 0; $j < $childres->num_rows; $j++) {
                                    $childrecord = $childres->fetch_assoc();

                                    $json->sedi[$i]->mesi[] = (array) [
                                        "mese" => $childrecord["mese"],
                                        "n_tessere_create" =>
                                            $childrecord["ntessere"],
                                    ];
                                }
                            }
                            echo json_encode($json);
                        }

                        $res->free();

                        break;

                    default:
                        //GET READ with unknown content
                        $statuscode = 400; //l'operazione ha restituito false per parametri invalidi
                        break;
                }
            } else {
                //GET READ with no content
                $statuscode = 400; //l'operazione ha restituito false per parametri insufficienti
            }
            break;

        default:
            //GET op other than READ
            $statuscode = 404; //operazione non presente nella web api
            break;
    }
} elseif ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Switch per gestire diverse operazioni basate sul valore di $op
    switch ($op) {
        // Caso per creare un nuovo cliente con tessera
        case "crea_clientetessera":
            // Verifica se tutti i parametri necessari sono stati inviati
            if (
                isset($_POST["nome"]) &&
                isset($_POST["cognome"]) &&
                isset($_POST["mail"]) &&
                isset($_POST["sede_id"])
            ) {
                try {
                    // Inizia una transazione per garantire l'atomicità delle operazioni
                    $conn->begin_transaction();

                    // Inserimento della persona nel database
                    $stmt = $conn->prepare(
                        "INSERT INTO persona (nome, cognome, mail) VALUES (?, ?, ?)"
                    );
                    $stmt->bind_param(
                        "sss",
                        $_POST["nome"],
                        $_POST["cognome"],
                        $_POST["mail"]
                    );
                    $stmt->execute();
                    // Ottieni l'ID della persona appena inserita
                    $cliente_id = $conn->insert_id;
                    var_dump($conn);

                    // Inserimento della tessera associata al cliente
                    $stmt = $conn->prepare(
                        "INSERT INTO tessera (sede_creazione_id, punti, cliente_id) VALUES (?, 0, ?)"
                    );
                    $stmt->bind_param("ii", $_POST["sede_id"], $cliente_id);
                    $stmt->execute();

                    // Conferma la transazione
                    if ($conn->commit()) {
                        $statuscode = 200; // operazione ha avuto sucesso
                    } else {
                        $statuscode = 204; //l'operazione non si è conessa corretamente
                    }
                } catch (Exception $e) {
                    $conn->rollback(); // In caso di errore, annulla la transazione
                    $statuscode = 500; // (Errore interno del server)
                }
            } else {
                $statuscode = 400; // non ci sono tutti i valori necessari per eseguire il valore
            }
            break;
        case "crea_sede":
            // Verifica se tutti i parametri necessari sono stati inviati
            if (isset($_POST["nome"]) && isset($_POST["indirizzo"])) {
                try {
                    // Inizia una transazione per garantire l'atomicità delle operazioni
                    $conn->begin_transaction();

                    // Inserimento della persona nel database
                    $stmt = $conn->prepare(
                        "INSERT INTO sede (nome, indirizzo) VALUES (?, ?)"
                    );
                    $stmt->bind_param(
                        "ss",
                        $_POST["nome"],
                        $_POST["indirizzo"]
                    );
                    $stmt->execute();

                    if ($conn->commit()) {
                        $statuscode = 200; // operazione ha avuto sucesso
                    } else {
                        $statuscode = 204; //l'operazione non si è conessa corretamente
                    }
                } catch (Exception $e) {
                    $conn->rollback(); // In caso di errore, annulla la transazione
                    $statuscode = 500; // (Errore interno del server)
                }
            } else {
                $statuscode = 400; // non ci sono tutti i valori necessari per eseguire il valore
            }
            break;
        case "crea_tessera":
            // Verifica se tutti i parametri necessari sono stati inviati
            if (isset($_POST["cliente_id"]) && isset($_POST["sede_id"])) {
                try {
                    // Inizia una transazione per garantire l'atomicità delle operazioni
                    $conn->begin_transaction();

                    // Inserimento della persona nel database
                    $stmt = $conn->prepare(
                        "INSERT INTO tessera (id, sede_creazione_id, cliente_id, punti, data_creazione) VALUES (NULL, ?, ?, 0, current_timestamp())"
                    );
                    if (!$stmt) {
                        throw new Exception("Prepare failed: " . $conn->error);
                    }

                    $stmt->bind_param(
                        "ss",
                        $_POST["sede_id"],
                        $_POST["cliente_id"]
                    );

                    if (!$stmt->execute()) {
                        throw new Exception("Execute failed: " . $stmt->error);
                    }

                    $conn->commit();
                    $statuscode = 200;
                } catch (Exception $e) {
                    echo "Errore: " . $e->getMessage(); // Logga l'errore
                    $statuscode = 500; // (Errore interno del server)
                }
            } else {
                $statuscode = 400; // non ci sono tutti i valori necessari per eseguire il valore
            }
            break;
        default:
            $statuscode = 404; //operazione non presente nella web api
            break;
    }
} elseif ($_SERVER["REQUEST_METHOD"] == "DELETE") {
    // Switch per gestire diverse operazioni basate sul valore di $op
    switch ($op) {
        // Caso per eliminare un cliente
        case "elimina_cliente":
            // Ottieni l'ID del cliente da eliminare
            $id = isset($_GET["id"]) ? $_GET["id"] : null;

            // Se l'ID non è stato fornito, imposta il codice di stato a 400 (Richiesta non valida)
            if ($id === null) {
                $statuscode = 400;
                break;
            }

            try {
                // Inizia una transazione per garantire l'atomicità delle operazioni
                $conn->begin_transaction();

                // Elimina la tessera associata al cliente
                $stmt = $conn->prepare(
                    "DELETE FROM tessera WHERE cliente_id = ?"
                );
                $stmt->bind_param("i", $id);
                $stmt->execute();

                // Elimina il cliente
                $stmt = $conn->prepare("DELETE FROM persona WHERE id = ?");
                $stmt->bind_param("i", $id);
                $stmt->execute();

                // Se nessuna riga è stata influenzata, il cliente non esiste
                if ($stmt->affected_rows === 0) {
                    $statuscode = 404;
                    throw new Exception("Cliente non trovato con ID: $id");
                }

                if ($conn->commit()) {
                    $statuscode = 200; // operazione ha avuto sucesso
                } else {
                    $conn->rollback(); // In caso di errore, annulla la transazione
                    $statuscode = 500; //l'operazione non si è conessa corretamente
                }
            } catch (Exception $e) {
                $conn->rollback(); // In caso di errore, annulla la transazione

                $statuscode = 500; // (Errore interno del server)
            }
            break;
        case "elimina_sede":
            $id = isset($_GET["id"]) ? $_GET["id"] : null;

            if ($id === null) {
                $statuscode = 400;
                break;
            }

            try {
                $conn->begin_transaction();

                $stmt = $conn->prepare("DELETE FROM sede WHERE id = ?");
                $stmt->bind_param("i", $id);
                $stmt->execute();

                // Se nessuna riga è stata influenzata, il cliente non esiste
                if ($stmt->affected_rows === 0) {
                    $statuscode = 404;
                    throw new Exception("Cliente non trovato con ID: $id");
                }

                if ($conn->commit()) {
                    $statuscode = 200; // operazione ha avuto sucesso
                } else {
                    $conn->rollback(); // In caso di errore, annulla la transazione
                    $statuscode = 500; //l'operazione non si è conessa corretamente
                }
            } catch (Exception $e) {
                $conn->rollback(); // In caso di errore, annulla la transazione

                $statuscode = 500; // (Errore interno del server)
            }

            break;
        case "elimina_tessera":
            // Ottieni l'ID della tessera da eliminare
            $id = isset($_GET["id"]) ? $_GET["id"] : null;

            // Se l'ID non è stato fornito, imposta il codice di stato a 400 (Richiesta non valida)
            if ($id === null) {
                $statuscode = 400;
                break;
            }

            try {
                // Inizia una transazione per garantire l'atomicità delle operazioni
                $conn->begin_transaction();

                // Elimina la tessera associata al cliente
                $stmt = $conn->prepare("DELETE FROM tessera WHERE id = ?");
                $stmt->bind_param("i", $id);
                $stmt->execute();

                // Se nessuna riga è stata influenzata, il cliente non esiste
                if ($stmt->affected_rows === 0) {
                    $statuscode = 404;
                    throw new Exception("Cliente non trovato con ID: $id");
                }

                if ($conn->commit()) {
                    $statuscode = 200; // operazione ha avuto sucesso
                } else {
                    $conn->rollback(); // In caso di errore, annulla la transazione
                    $statuscode = 500; //l'operazione non si è conessa corretamente
                }
            } catch (Exception $e) {
                $conn->rollback(); // In caso di errore, annulla la transazione

                $statuscode = 500; // (Errore interno del server)
            }
            break;
        default:
            $statuscode = 404; //operazione non presente nella web api
            break;
    }
} elseif (
    $_SERVER["REQUEST_METHOD"] == "PATCH" ||
    $_SERVER["REQUEST_METHOD"] == "PUT"
) {
    $input = file_get_contents("php://input"); //prendo il body della richiesta HTTP
    $content_type = $_SERVER["CONTENT_TYPE"]; //prendo il tipo di contenuto passato dall'header HTTP Content-Type

    if ($content_type == "application/json") {
        $input = json_decode($input, false); //trasformo la stringa json in un oggetto standard
    } elseif ($content_type == "application/xml") {
        //trasformo la string xml in un oggetto standard in modo da standardificare il processo di elaborazione dei dati
        $input = simplexml_load_string($input);
        $input = json_encode($input);
        $input = json_decode($input, false);
    } else {
        $input = json_decode($input, false);

        if ($input === null) {
            $statuscode = 404;
        }
    }

    foreach ($input as $table => $values) {
        //scorro il body tra gli elementi da modificare
        if ($table == "persona" || $table == "sede" || $table == "tessera") {
            //tabelle accettate
            $params = []; //array che per ogni cella ha una stringa "colonna = nuovo_valore"
            foreach ($values as $key => $value) {
                //scorro tra gli attributi di un singolo elemento
                if ($key == "id") {
                    $id = intval($value) ?? -1; //prendo l'id della riga da modificare
                } else {
                    $params[] = " " . $key . " = '" . $value . "' "; //"colonna = nuovo_valore"
                }
            }
            if ($id > -1) {
                //se è un id valido
                $params = implode(",", $params); //unisco con una virgola le singole assegnazioni colonna=val in una singola stringa (es "colonna=val, colonna=val, colonna=val")
                $query = "UPDATE $table SET $params WHERE id=$id"; //modifico il singolo elemento identificato da un id e con i parametri dati
                if ($conn->query($query) === false) {
                    //se la query da errore ritorno Internal Server Error
                    $statuscode = 500;
                } else {
                    $statuscode = 200;
                }
            } else {
                $statuscode = 400; //se l'id è non valido ritorno Bad Request
            }
        } else {
            $statuscode = 400; //se mi chiede di modificare una tabella non valida ritorno Bad Request
        }
    }
} else {
    $statuscode = 404;
}

http_response_code($statuscode); //invio lo status code della risposta
$conn->close();
?>
