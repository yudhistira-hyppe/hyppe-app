import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';

class DialogInfoWidget extends StatelessWidget {
  final LocalizationModelV2? lang;
  const DialogInfoWidget({super.key, required this.lang});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      maxChildSize: .9,
      // initialChildSize: .4,
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
                  lang?.requiredgift??'Syarat Menerima Gift',
                  style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              tenPx,
              const Divider(color: kHyppeBurem, thickness: .5,),
              tenPx,
              listText(context, number: 1, 
                label: lang!.localeDatetime == 'id' 
                ? 'Lulus NSFW: Konten tidak boleh mengandung unsur pornografi, kekerasan, atau konten dewasa lainnya yang melanggar Pedoman Komunitas.'
                : 'NSFW compliance: Content must not contain pornography, violence, or other adult content that violates the Community Guidelines.'),
              listText(context, number: 2, 
                label: lang!.localeDatetime == 'id' 
                ? 'Kepemilikan Konten: Konten harus dibuat sendiri oleh kreator, terdaftar dan memiliki sertifikat content.'
                : 'Content ownership: Content must be created by the creator themselves, registered and have a content certificate.'),
              listText(context, number: 3, 
                label: lang!.localeDatetime == 'id' 
                ? 'Moderasi Konten: Jika konten dilaporkan dan sedang dalam proses moderasi, maka konten tidak dapat menerima Gift sampai proses selesai.'
                : 'Content moderation: If content is reported and under moderation, it cannot receive Gifts until the process is complete.'),
              listText(context, number: 4, 
                label: lang!.localeDatetime == 'id' 
                ? 'Status Konten Tidak Dijual: Konten yang sedang dijual di marketplace konten tidak dapat menerima Gift.'
                : 'Content not for sale: Content that is being sold on the content marketplace cannot receive Gifts.'),
              listText(context, number: 5, 
                label: lang!.localeDatetime == 'id' 
                ? 'Boost Post: Konten yang dipromosikan melalui layanan Boost Post tetap dapat menerima Gift.'
                : 'Boosted posts: Content promoted through the Boost Post service can still receive Gifts.'),
            ],
          ),
        );
      },
    );
  }

  Widget listText(BuildContext context,{int number = 1, String label = ''}) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextWidget(textToDisplay: '$number.  '),
            SizedBox(
              width: MediaQuery.of(context).size.width * .9,
              child: Text(
                label,
                maxLines: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}