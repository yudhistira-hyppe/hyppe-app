import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';

class TextInfo extends StatelessWidget {
  final LocalizationModelV2? lang;
  const TextInfo({super.key, this.lang});

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
                  lang?.localeDatetime == 'id' ? 'Ketentuan Penarikan' : 'Withdrawal Terms',
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
                    listText(context, number: 1, label: lang?.localeDatetime == 'id' 
                      ? 'Penukaran coins tersedia untuk real account dengan rekening bank yang telah terverifikasi.'
                      : 'Coin exchange is available for verified real accounts with a linked bank account.'
                    ),
                    fivePx,
                    listText(context, number: 2, label: lang?.localeDatetime == 'id' 
                      ? 'Penukaran coins memiliki batas jumlah maksimum dan minimum per hari. '
                      : 'Coin exchange has daily minimum and maximum limits.'
                    ),
                    fivePx,
                    listText(context, number: 3, label: lang?.localeDatetime == 'id' 
                      ? 'Pengguna akan dikenakan biaya transaksi dan biaya penukaran coins.'
                      : 'Transaction and coin exchange fees apply.'
                    ),
                    fivePx,
                    listText(context, number: 4, label: lang?.localeDatetime == 'id'
                      ? 'Penukaran coins memerlukan kode PIN'
                      : 'PIN verification is required for coin exchange.'
                    ),
                    fivePx,
                    listText(context, number: 5, label: lang?.localeDatetime == 'id'
                      ? 'Proses pengajuan memerlukan 3-5 hari kerja untuk verifikasi data.'
                      : 'Data verification takes 3-5 business days.'
                    ),
                    fivePx,
                    listText(context, number: 6, label: lang?.localeDatetime == 'id'
                      ? 'Jika penukaran coins berhasil, Pengguna akan mendapatkan pemberitahuan.'
                      : 'Users will be notified of successful coin exchange.'
                    ),
                    fivePx,
                    listText(context, number: 7, label: lang?.localeDatetime == 'id'
                      ? 'Jika terjadi kegagalan proses penukaran coins, pengguna tidak dikenakan biaya apapun.'
                      : 'No fees will be charged for failed coin exchange.'
                    ),
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