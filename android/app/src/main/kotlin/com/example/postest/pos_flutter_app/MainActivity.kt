package com.example.postest.pos_flutter_app

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.IBinder
import android.os.RemoteException
import android.util.Log

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

import com.iposprinter.iposprinterservice.IPosPrinterService
import com.iposprinter.iposprinterservice.IPosPrinterCallback

import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import android.graphics.BitmapFactory

class MainActivity : FlutterActivity() {

    private val CHANNEL =
        "com.example.postest.pos_flutter_app/printer"

    private var printerService: IPosPrinterService? = null

    private var isPrinterBound = false

    // =========================================================
    // CALLBACK IMPRIMANTE
    // =========================================================

    private val callback = object : IPosPrinterCallback.Stub() {

        override fun onRunResult(isSuccess: Boolean) {
            Log.d("PRINTER", "Run: $isSuccess")
        }

        override fun onReturnString(result: String?) {
            Log.d("PRINTER", "Result: $result")
        }
    }

    // =========================================================
    // CONNEXION AU SERVICE IPOS
    // =========================================================

    private val serviceConnection = object : ServiceConnection {

        override fun onServiceConnected(
            name: ComponentName?,
            service: IBinder?
        ) {
            printerService =
                IPosPrinterService.Stub.asInterface(service)

            isPrinterBound = true

            Log.d(
                "PRINTER_SERVICE",
                "Connected OK"
            )
        }

        override fun onServiceDisconnected(
            name: ComponentName?
        ) {
            printerService = null
            isPrinterBound = false

            Log.d(
                "PRINTER_SERVICE",
                "Disconnected"
            )
        }
    }

    // =========================================================
    // CONFIGURATION FLUTTER
    // =========================================================

    override fun configureFlutterEngine(
        flutterEngine: FlutterEngine
    ) {
        super.configureFlutterEngine(flutterEngine)

        // -----------------------------------------------------
        // Connexion au service imprimante
        // -----------------------------------------------------

        val intent = Intent().apply {

            setPackage(
                "com.iposprinter.iposprinterservice"
            )

            action =
                "com.iposprinter.iposprinterservice.IPosPrintService"
        }

        try {

            isPrinterBound = bindService(
                intent,
                serviceConnection,
                Context.BIND_AUTO_CREATE
            )

            Log.d(
                "PRINTER_SERVICE",
                "bindService = $isPrinterBound"
            )

        } catch (e: Exception) {

            Log.e(
                "PRINTER_SERVICE",
                "Erreur connexion imprimante",
                e
            )
        }

        // =====================================================
        // METHOD CHANNEL FLUTTER
        // =====================================================

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            if (call.method == "printText") {

                try {

                    val data =
                        call.arguments as Map<String, Any>

                    val nom =
                        data["non"]?.toString() ?: ""

                    val appareil =
                        data["app"]?.toString() ?: ""

                    val marque =
                        data["mak"]?.toString() ?: ""

                    val etat =
                        data["eta"]?.toString() ?: ""

                    val prix =
                        data["pri"]?.toString() ?: ""

                    val code =
                        data["kod"]?.toString() ?: ""

                    // =================================================
                    // PREMIÈRE IMPRESSION
                    // =================================================

                    printTicket(
                        nom = nom,
                        appareil = appareil,
                        marque = marque,
                        etat = etat,
                        prix = prix,
                        code = code
                    )

                    // =================================================
                    // DEUXIÈME IMPRESSION APRÈS 7 SECONDES
                    // =================================================

                    Thread {

                        try {

                            Thread.sleep(10000)

                            runOnUiThread {

                                Log.d(
                                    "PRINTER",
                                    "Deuxième impression après 7 secondes"
                                )

                                printTicket(
                                    nom = nom,
                                    appareil = appareil,
                                    marque = marque,
                                    etat = etat,
                                    prix = prix,
                                    code = code
                                )
                            }

                        } catch (e: Exception) {

                            Log.e(
                                "PRINTER",
                                "Erreur deuxième impression",
                                e
                            )
                        }

                    }.start()

                    result.success(
                        "2 impressions lancées"
                    )

                } catch (e: Exception) {

                    Log.e(
                        "PRINTER",
                        "Erreur MethodChannel",
                        e
                    )

                    result.error(
                        "PRINT_ERROR",
                        e.message,
                        null
                    )
                }

            } else {

                result.notImplemented()
            }
        }
    }



    private fun printLogo() {

        if (printerService == null) {
            Log.e("PRINTER", "printerService null dans printLogo")
            return
        }

        try {

            val bitmap = BitmapFactory.decodeResource(
                resources,
                R.drawable.boolbi
            )

            if (bitmap == null) {
                Log.e("PRINTER", "Impossible de charger logo.png")
                return
            }

            // Centrer l'image
            printerService?.setPrinterPrintAlignment(
                1,
                callback
            )

            // Taille de l'image
            printerService?.printBitmap(
                1,
                384,
                bitmap,
                callback
            )

            // Petit espace après le logo
            printerService?.printBlankLines(
                1,
                10,
                callback
            )

        } catch (e: Exception) {

            Log.e(
                "PRINTER",
                "Erreur impression logo",
                e
            )
        }
    }

    // =========================================================
    // DATE AUTOMATIQUE EN FRANÇAIS
    // =========================================================

    private fun formatTicketDate(): String {

        val locale = Locale.FRENCH

        val dateFormat = SimpleDateFormat(
            "EEEE d MMMM yyyy 'a' h'h' mma",
            locale
        )

        return dateFormat
            .format(Date())
            .replaceFirstChar {

                if (it.isLowerCase()) {

                    it.titlecase(locale)

                } else {

                    it.toString()
                }
            }
    }

    // =========================================================
    // TEXTE CENTRÉ
    // =========================================================

    private fun printCentered(
        text: String,
        fontSize: Int
    ) {

        if (printerService == null) {

            Log.e(
                "PRINTER",
                "printerService null dans printCentered"
            )

            return
        }

        try {

            printerService?.setPrinterPrintAlignment(
                1,
                callback
            )

            printerService?.setPrinterPrintFontSize(
                fontSize,
                callback
            )

            printerService?.printText(
                "$text\n",
                callback
            )

        } catch (e: Exception) {

            Log.e(
                "PRINTER",
                "Erreur printCentered",
                e
            )
        }
    }

    // =========================================================
    // INFORMATIONS ALIGNÉES À GAUCHE
    // =========================================================

    private fun printInfo(
        label: String,
        value: String,
        fontSize: Int = 24
    ) {

        if (printerService == null) {

            Log.e(
                "PRINTER",
                "printerService null dans printInfo"
            )

            return
        }

        try {

            val maxChars = 32
            val labelWidth = 11
            val valueWidth =
                maxChars - labelWidth

            val cleanLabel =
                label.trim()

            val cleanValue =
                value.trim()

            printerService?.setPrinterPrintAlignment(
                0,
                callback
            )

            printerService?.setPrinterPrintFontSize(
                fontSize,
                callback
            )

            // ---------------------------------------------
            // Valeur vide
            // ---------------------------------------------

            if (cleanValue.isEmpty()) {

                printerService?.printText(
                    "${cleanLabel.padEnd(labelWidth)}\n",
                    callback
                )

                return
            }

            // ---------------------------------------------
            // Découpage des valeurs longues
            // ---------------------------------------------

            val lines =
                cleanValue.chunked(valueWidth)

            // Première ligne

            printerService?.printText(
                cleanLabel.padEnd(labelWidth) +
                        lines[0] +
                        "\n",
                callback
            )

            // Lignes suivantes

            for (i in 1 until lines.size) {

                printerService?.printText(
                    " ".repeat(labelWidth) +
                            lines[i] +
                            "\n",
                    callback
                )
            }

        } catch (e: Exception) {

            Log.e(
                "PRINTER",
                "Erreur printInfo",
                e
            )
        }
    }

    // =========================================================
    // EN-TÊTE
    // =========================================================

    private fun printHeaderProMax() {

        if (printerService == null) {

            Log.e(
                "PRINTER",
                "printerService null dans printHeaderProMax"
            )

            return
        }

        try {

            // Petit espace en haut

            printerService?.printBlankLines(
                1,
                16,
                callback
            )

            // -------------------------------------------------
            // NOM DU COMMERCE
            // -------------------------------------------------

            printCentered(
                "Boolbi Konpleks",
                80
            )

            // -------------------------------------------------
            // ADRESSE
            // -------------------------------------------------

            printCentered(
                "Ri Dormeus, Ryel Lapaix",
                25
            )

            // -------------------------------------------------
            // TÉLÉPHONE
            // -------------------------------------------------

            printCentered(
                "Tel: +509 48 65 5874",
                24
            )

            // -------------------------------------------------
            // SLOGAN
            // -------------------------------------------------

            printCentered(
                "Sevis rapid & fyab",
                22
            )

            // -------------------------------------------------
            // SÉPARATEUR
            // -------------------------------------------------

            printCentered(
                "================================",
                24
            )

            // Espace

            printerService?.printBlankLines(
                2,
                16,
                callback
            )

            // Retour alignement gauche

            printerService?.setPrinterPrintAlignment(
                0,
                callback
            )

        } catch (e: Exception) {

            Log.e(
                "PRINTER",
                "Header error",
                e
            )
        }
    }

    // =========================================================
    // IMPRESSION DE LA FICHE
    // =========================================================

    private fun printTicket(
        nom: String,
        appareil: String,
        marque: String,
        etat: String,
        prix: String,
        code: String
    ) {

        if (printerService == null) {

            Log.e(
                "PRINTER",
                "Impossible d'imprimer : service null"
            )

            return
        }

        try {
            printLogo()

            // =================================================
            // EN-TÊTE
            // =================================================

            printHeaderProMax()

            // =================================================
            // CODE
            // =================================================

            printCentered(
                code,
                60
            )

            // =================================================
            // SÉPARATEUR
            // =================================================

            printerService?.printSpecifiedTypeText(
                "================================\n",
                "ST",
                24,
                callback
            )

            printerService?.printBlankLines(
                1,
                16,
                callback
            )

            // =================================================
            // CLIENT
            // =================================================

            printInfo(
                label = "Kliyan :",
                value = nom,
                fontSize = 24
            )

            printerService?.printBlankLines(
                1,
                5,
                callback
            )

            // =================================================
            // APPAREIL
            // =================================================

            printInfo(
                label = "Aparey :",
                value = "$appareil / $marque",
                fontSize = 24
            )

            printerService?.printBlankLines(
                1,
                5,
                callback
            )

            // =================================================
            // ÉTAT
            // =================================================

            printInfo(
                label = "Eta :",
                value = etat,
                fontSize = 24
            )

            printerService?.printBlankLines(
                1,
                5,
                callback
            )

            // =================================================
            // DATE AUTOMATIQUE
            // =================================================

            printCentered(
                formatTicketDate(),
                22
            )

            // =================================================
            // ESPACE
            // =================================================

            printerService?.printBlankLines(
                1,
                16,
                callback
            )

            // =================================================
            // SÉPARATEUR
            // =================================================

            printerService?.printSpecifiedTypeText(
                "--------------------------------\n",
                "ST",
                24,
                callback
            )

            // =================================================
            // TOTAL
            // =================================================

            printCentered(
                "PRI : $prix HTG",
                36
            )

            // =================================================
            // SÉPARATEUR
            // =================================================

            printerService?.printSpecifiedTypeText(
                "--------------------------------\n",
                "ST",
                24,
                callback
            )

            // =================================================
            // ESPACE
            // =================================================

            printerService?.printBlankLines(
                2,
                16,
                callback
            )

            // =================================================
            // MESSAGE
            // =================================================

            printCentered(
                "PA PEDI FICH LA, SE AVEK LI POUW VIN PRAN APAREY OU A !",
                28
            )

            printerService?.printBlankLines(
                3,
                16,
                callback
            )

            printCentered(
                "Mesi paske ou chwazi pran sevis nan men non",
                20
            )

            // =================================================
            // ESPACE FINAL
            // =================================================

            printerService?.printBlankLines(
                1,
                12,
                callback
            )

            // =================================================
            // COUPE / FIN D'IMPRESSION
            // =================================================

            printerService?.printerPerformPrint(
                160,
                callback
            )

            Log.d(
                "PRINTER",
                "Fiche envoyée à l'imprimante"
            )

        } catch (e: RemoteException) {

            Log.e(
                "PRINTER",
                "Erreur RemoteException",
                e

            )

        } catch (e: Exception) {

            Log.e(
                "PRINTER",
                "Erreur impression",
                e
            )
        }
    }

    // =========================================================
    // DESTRUCTION
    // =========================================================

    override fun onDestroy() {

        try {

            if (isPrinterBound) {

                unbindService(
                    serviceConnection
                )

                isPrinterBound = false
            }

        } catch (e: Exception) {

            Log.e(
                "PRINTER_SERVICE",
                "Erreur unbindService",
                e
            )
        }

        printerService = null

        super.onDestroy()
    }
}