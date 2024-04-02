import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';

class TextInfo extends StatelessWidget {
  const TextInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      maxChildSize: .9,
      builder: (_, controller) {
        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
          ),
          child: Column(
            children: [
              FractionallySizedBox(
                widthFactor: 0.15,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 12.0,
                  ),
                  child: Container(
                    height: 5.0,
                    decoration: const BoxDecoration(
                      color: kHyppeBurem,
                      borderRadius: BorderRadius.all(Radius.circular(2.5)),
                    ),
                  ),
                ),
              ),
              Center(
                child: Text(
                  'Ketentuan Penarikan',
                  style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              fivePx,
              const Divider(
                color: kHyppeBurem,
              ),
              fivePx,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  children: [
                    listText(context, number: 1, label: 'Penarikan tersedia untuk rekening bank yang telah terverifikasi oleh akun premium.'),
                    fivePx,
                    listText(context, number: 2, label: 'Jumlah penarikan per hari minimal Rp50.000, dan maksimal Rp50.000.000.'),
                    fivePx,
                    listText(context, number: 3, label: 'Pengguna akan dikenakan biaya transaksi sebesar Rp6.000 dipotong dari jumlah penarikan.'),
                    fivePx,
                    listText(context, number: 4, label: 'Penarikan memerlukan kode PIN dan konfirmasi email.'),
                    fivePx,
                    listText(context, number: 5, label: 'Email konfirmasi berlaku selama 15 menit.'),
                    fivePx,
                    listText(context, number: 6, label: 'Proses pengajuan memerlukan 3-5 hari kerja untuk validasi data.'),
                    fivePx,
                    listText(context, number: 7, label: 'Jika terjadi kegagalan proses penarikan, pengguna tetap dikenakan biaya transaksi sebesar Rp6.000.'),
                    fivePx,
                    listText(context, number: 8, label: 'Penarikan dikirim langsung ke rekening dituju pengguna. Notifikasi akan diterima pengguna melalui aplikasi dan email.'),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget listText(BuildContext context, {required int number, required String label}){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$number.'),
        fivePx,
        SizedBox(
          width: MediaQuery.of(context).size.width * .8,
          child: Text(label))
      ],
    );
  }
}