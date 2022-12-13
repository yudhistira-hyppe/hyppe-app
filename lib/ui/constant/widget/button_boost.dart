import 'package:flutter/material.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/core/arguments/update_contents_argument.dart';
import 'package:hyppe/core/constants/kyc_status.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class ButtonBoost extends StatelessWidget {
  final ContentData? contentData;
  final bool marginBool;
  const ButtonBoost({Key? key, this.contentData, this.marginBool = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _isKyc = SharedPreference().readStorage(SpKeys.statusVerificationId);
    return Container(
      margin: EdgeInsets.all(marginBool ? 0.0 : 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: _isKyc == VERIFIED ? kHyppePrimary : kHyppeDisabled,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: _isKyc == VERIFIED
                ? () async{
                    final notifier = Provider.of<PreUploadContentNotifier>(context, listen: false);
                    notifier.editData = contentData;
                    notifier.isEdit = true;
                    notifier.isUpdate = true;
                    notifier.captionController.text = contentData?.description ?? "";
                    notifier.tagsController.text = contentData?.tags?.join(",") ?? '';
                    notifier.featureType = System().getFeatureTypeV2(contentData?.postType ?? '');

                    notifier.thumbNail = contentData?.fullThumbPath;
                    notifier.allowComment = contentData?.allowComments ?? false;
                    notifier.certified = contentData?.certified ?? false;
                    notifier.ownershipEULA = contentData?.certified ?? false;

                    if (contentData?.location != '') {
                      notifier.locationName = contentData?.location ?? '';
                    } else {
                      notifier.locationName = notifier.language.addLocation ?? '';
                    }
                    notifier.privacyTitle = contentData?.visibility ?? '';

                    notifier.privacyValue = contentData?.visibility ?? '';
                    final _isoCodeCache = SharedPreference().readStorage(SpKeys.isoCode);

                    if (_isoCodeCache == 'id') {
                      switch (contentData?.visibility ?? '') {
                        case 'PUBLIC':
                          notifier.privacyTitle = 'Umum';
                          break;
                        case 'FRIEND':
                          notifier.privacyTitle = 'Teman';
                          break;
                        case 'PRIVATE':
                          notifier.privacyTitle = 'Hanya saya';
                          break;
                        default:
                      }
                    } else {
                      notifier.privacyValue = contentData?.visibility ?? '';
                    }

                    notifier.interestData = [];
                    if (contentData?.cats != null) {
                      contentData?.cats!.map((val) {
                        notifier.interestData.add(val.interestName ?? '');
                      }).toList();
                    }
                    notifier.userTagData = [];
                    if (contentData?.tagPeople != null) {
                      contentData?.tagPeople!.map((val) {
                        notifier.userTagData.add(val.username ?? '');
                      }).toList();
                    }
                    notifier.userTagDataReal = [];
                    notifier.userTagDataReal.addAll(contentData?.tagPeople ?? []);

                    notifier.toSell = contentData?.saleAmount != null && (contentData?.saleAmount ?? 0) > 0 ? true : false;
                    notifier.includeTotalViews = contentData?.saleView ?? false;
                    notifier.includeTotalLikes = contentData?.saleLike ?? false;
                    notifier.certified = contentData?.certified ?? false;
                    notifier.priceController.text = contentData?.saleAmount?.toInt().toString() ?? '';

                    if(globalAudioPlayer != null){
                      globalAudioPlayer!.pause();
                    }

                    Routing()
                        .move(
                          Routes.preUploadContent,
                          argument: UpdateContentsArgument(onEdit: true, contentData: contentData, content: ''),
                        )
                        .whenComplete((){
                      if(globalAudioPlayer != null){
                        globalAudioPlayer!.resume();
                      }
                          Routing().moveBack();
                        });
                  }
                : null,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              width: SizeConfig.screenWidth,
              child: Text(
                'Boost',
                style: Theme.of(context).primaryTextTheme.subtitle2?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
