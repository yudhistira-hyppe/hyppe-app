import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';

class InfoDialog extends StatelessWidget {
  final LocalizationModelV2? lang;
  const InfoDialog({super.key, required this.lang});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        expand: false,
        maxChildSize: .9,
        initialChildSize: .25,
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
                    widthFactor: 0.1,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 12.0,
                      ),
                      child: Container(
                        height: 5.0,
                        decoration: BoxDecoration(
                          color: kHyppeBurem.withOpacity(.5),
                          borderRadius: const BorderRadius.all(Radius.circular(2.5)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: kToolbarHeight - 24,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: Text(
                        lang?.localeDatetime == 'id' ? 'Tentang Pesanan Kamu' : 'About Your Order',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const Divider(
                    thickness: .1,
                    color: kHyppeBurem,
                  ),
                    listTile(context, '1. ', lang?.localeDatetime == 'id' ? 'Terdapat 2  jenis status, yaitu: "Gagal" dan "Menunggu Pembayaran".' : 'There are 2 types of statuses: "Failed" and "Awaiting Payment."'),
                    listTile(context,  '2. ', lang?.localeDatetime == 'id' ? 'Maksimal hanya memiliki 1 transaksi dengan status “Menunggu Pembayaran”.' : 'You can have a maximum of 1 transaction with the status "Awaiting Payment."'),
                ],  
              ));
        });
  }

  Widget listTile(BuildContext context, String? label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 18.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label??'',
            style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.normal),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * .8,
            child: Text(value??'',
              style: const TextStyle(
                  color: kHyppeBurem,
                  fontWeight: FontWeight.normal),
            ),
          )
        ],
      ),
    );
  }
}
