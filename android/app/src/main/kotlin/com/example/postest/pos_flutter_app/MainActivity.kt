package com.example.postest.pos_flutter_app

import android.content.*
import android.os.IBinder
import android.os.RemoteException
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.iposprinter.iposprinterservice.IPosPrinterService
import com.iposprinter.iposprinterservice.IPosPrinterCallback

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.example.postest.pos_flutter_app/printer"
    private var printerService: IPosPrinterService? = null

    // =========================
    // CALLBACK SAFE
    // =========================
    private val callback = object : IPosPrinterCallback.Stub() {
        override fun onRunResult(isSuccess: Boolean) {
            Log.d("PRINTER", "Run: $isSuccess")
        }

        override fun onReturnString(result: String?) {
            Log.d("PRINTER", "Result: $result")
        }
    }

    // =========================
    // SERVICE CONNECTION
    // =========================
    private val serviceConnection = object : ServiceConnection {

        override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
            printerService = IPosPrinterService.Stub.asInterface(service)
            Log.d("PRINTER_SERVICE", "Connected OK")
        }

        override fun onServiceDisconnected(name: ComponentName?) {
            printerService = null
            Log.d("PRINTER_SERVICE", "Disconnected")
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val intent = Intent().apply {
            setPackage("com.iposprinter.iposprinterservice")
            action = "com.iposprinter.iposprinterservice.IPosPrintService"
        }

        bindService(intent, serviceConnection, Context.BIND_AUTO_CREATE)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->

                if (call.method == "printText") {

                    val data = call.arguments as Map<String, Any>

                    printTicket(
                        data["non"].toString(),
                        data["mak"].toString(),
                        data["eta"].toString(),
                        data["pri"].toString(),
                        data["dat"].toString(),
                        data["kod"].toString()
                    )

                    result.success("OK PRINT")
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun printHeaderProMax() {

        if (printerService == null) return

        try {

            // =========================
            // ESPACE DE SÉCURITÉ (IMPORTANT)
            // =========================
            printerService?.printBlankLines(1, 16, callback)

            // =========================
            // TITRE (FORCÉ CENTRÉ VISUEL)
            // =========================
            printerService?.PrintSpecFormatText(
                "LSB MILTI SEVIS\n",
                "ST",
                30,
                2,
                callback
            )

            // =========================
            // SOUS TITRE (ADRESSE)
            // =========================
            printerService?.printSpecifiedTypeText(
                "Rue Dormeus, Ruelle Lapaix\n",
                "ST",
                24,
                callback
            )

            // =========================
            // CONTACT
            // =========================
            printerService?.printSpecifiedTypeText(
                "Tel: +509 48 65 5874\n",
                "ST",
                24,
                callback
            )

            // =========================
            // EMAIL OU SLOGAN (OPTIONNEL PRO)
            // =========================
            printerService?.printSpecifiedTypeText(
                "Service rapide & fiable\n",
                "ST",
                22,
                callback
            )

            // =========================
            // LIGNE PRO STYLE FACTURE
            // =========================
            printerService?.printSpecifiedTypeText(
                "================================\n",
                "ST",
                24,
                callback
            )

            // =========================
            // ESPACE FINAL HEADER
            // =========================
            printerService?.printBlankLines(2, 16, callback)

        } catch (e: Exception) {
            Log.e("PRINTER", "Header Pro Max error: ${e.message}")
        }
    }

    // =========================
    // PRINT PRO DESIGN
    // =========================
    private fun printTicket(
        nom: String,
        marque: String,
        etat: String,
        prix: String,
        date: String,
        code: String
    ) {
        printHeaderProMax();

        if (printerService == null) return

        try {

            // =========================
            // HEADER STYLE SUPERMARCHE
            // =========================
            printerService?.PrintSpecFormatText(
                "LSB MILTI SEVIS\n",
                "ST",
                30,
                2,
                callback
            )

            printerService?.printSpecifiedTypeText(
                "Rue Dormeus, Ruelle Lapaix\n",
                "ST",
                22,
                callback
            )

            printerService?.printSpecifiedTypeText(
                "Tel: +509 48 65 5874\n",
                "ST",
                22,
                callback
            )

            printerService?.printBlankLines(1, 16, callback)

            // =========================
            // LIGNE SEPARATION
            // =========================
            printerService?.printSpecifiedTypeText(
                "================================\n",
                "ST",
                24,
                callback
            )

            // =========================
            // CODE TICKET (STYLE JUMIA)
            // =========================
            printerService?.PrintSpecFormatText(
                "$code\n",
                "ST",
                48,
                1,
                callback
            )

            printerService?.printSpecifiedTypeText(
                "================================\n",
                "ST",
                24,
                callback
            )

            printerService?.printBlankLines(1, 16, callback)

            // =========================
            // INFOS CLIENT / PRODUIT
            // =========================
            printerService?.printSpecifiedTypeText(
                "Kliyan :................ $nom\n",
                "ST",
                24,
                callback
            )

            printerService?.printBlankLines(1, 5, callback)

            printerService?.printSpecifiedTypeText(
                "Aparey :................. $marque\n",
                "ST",
                24,
                callback
            )
            printerService?.printBlankLines(1, 5, callback)
            printerService?.printSpecifiedTypeText(
                "Eta :................. $etat\n",
                "ST",
                24,
                callback
            )
            printerService?.printBlankLines(1, 5, callback)
            printerService?.printSpecifiedTypeText(
                "DATE : $date\n",
                "ST",
                22,
                callback
            )

            printerService?.printBlankLines(1, 16, callback)

            // =========================
            // TOTAL (STYLE CAISSE)
            // =========================
            printerService?.printSpecifiedTypeText(
                "--------------------------------\n",
                "ST",
                24,
                callback
            )

            printerService?.PrintSpecFormatText(
                "TOTAL : $prix HTG\n",
                "ST",
                36,
                2,
                callback
            )

            printerService?.printSpecifiedTypeText(
                "--------------------------------\n",
                "ST",
                24,
                callback
            )

            printerService?.printBlankLines(2, 16, callback)

            // =========================
            // FOOTER STYLE JUMIA
            // =========================
            printerService?.PrintSpecFormatText(
                "MERCI POUR VOTRE VISITE\n",
                "ST",
                28,
                2,
                callback
            )

            printerService?.PrintSpecFormatText(
                "PA PEDI FICH LA\n",
                "ST",
                20,
                1,
                callback
            )

            printerService?.printBlankLines(3, 16, callback)

            printerService?.printerPerformPrint(160, callback)

        } catch (e: RemoteException) {
            Log.e("PRINTER", "Erreur: ${e.message}")
        }
    }


    override fun onDestroy() {
        super.onDestroy()
        unbindService(serviceConnection)
    }
}