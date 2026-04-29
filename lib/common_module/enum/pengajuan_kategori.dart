enum PengajuanKategori {
  cuti,
  lembur,
  dinas,
  wfh,
  izin,
  presensiBackdate
}

extension PengajuanKategoriExt on PengajuanKategori {
  String get value {
    switch (this) {
      case PengajuanKategori.cuti:
        return "cuti";
      case PengajuanKategori.lembur:
        return "lembur";
      case PengajuanKategori.dinas:
        return "dinas";
      case PengajuanKategori.wfh:
        return "wfh";
      case PengajuanKategori.izin:
        return "izin";

      case PengajuanKategori.presensiBackdate:
        return "backdate";
    }
  }
}