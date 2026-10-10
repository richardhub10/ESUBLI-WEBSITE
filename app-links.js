// ========================================================================
// eSUBLI: Pamana sa Sulat - Configuration para sa App Links & Files
// DITO MO ILALAGAY ANG IYONG PLAY STORE AT APK DOWNLOAD LINKS
// ========================================================================

const APP_CONFIG = {
  // 1. Direktang link sa iyong Android APK file (nasa downloads/ folder):
  apkDownloadUrl: "downloads/eSUBLI_v1.0.4.apk",
  apkFileName: "eSUBLI_v1.0.4.apk",
  apkVersion: "v1.0.4-release",
  apkFileSize: "24.5 MB",

  // 2. Opisyal na Google Play Store link:
  // Palitan ito ng totoong link ng iyong app sa Play Store kapag live na:
  playStoreUrl: "https://play.google.com/store/apps/details?id=com.esubli.kulitan",

  // Kung 'true', magpapakita muna ito ng 'Paparating na sa Play Store' notice.
  // Kung 'false', direktang pupunta sa iyong Play Store page kapag pinindot!
  playStoreComingSoon: true,

  // 3. FOLDER PARA SA MGA TOTOONG KULITAN SYMBOLS / LARAWAN:
  // Dito kukunin ng website ang mga larawan (PNG, SVG, JPG) para mapalitan
  // ang mga placeholder symbols ng totoong Sulat Kapampangan.
  // Folder para sa na-crop na malinis na simbolo: "symbols/pure/"
  symbolsFolder: "symbols/pure/",

  // Format ng filenames na babasahin ng website:
  // Halimbawa: "symbols/pure/ka.png", "symbols/pure/ga.png", etc.
  symbolExtension: "png" // "png", "svg", o "jpg"
};

// Helper function para buksan ang Play Store
function openPlayStoreLink() {
  if (APP_CONFIG.playStoreComingSoon) {
    if (typeof triggerToastNotice === "function") {
      triggerToastNotice("Coming soon to Google Play Store! You can download the direct APK below (Paparating na).");
    } else {
      alert("Coming soon to Google Play Store! Paparating na.");
    }
  } else if (APP_CONFIG.playStoreUrl && APP_CONFIG.playStoreUrl !== "#") {
    window.open(APP_CONFIG.playStoreUrl, "_blank");
  }
}

// Helper function para simulan ang APK download
function startApkDownload() {
  if (typeof triggerToastNotice === "function") {
    triggerToastNotice("Starting download of " + APP_CONFIG.apkFileName + "... (Nagsisimula na ang pag-download)");
  }
  const link = document.createElement("a");
  link.href = APP_CONFIG.apkDownloadUrl;
  link.download = APP_CONFIG.apkFileName;
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
}
