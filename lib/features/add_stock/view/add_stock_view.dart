import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vilsa/core/components/general_button.dart';
import 'package:vilsa/core/components/general_text.dart';
import 'package:vilsa/core/components/success_dialog.dart';
import 'package:vilsa/core/constants/color_constants.dart';
import 'package:vilsa/core/constants/padding_constants.dart';
import 'package:vilsa/core/extensions/context_extension.dart';
import 'package:vilsa/core/extensions/price_input_formatter.dart';
import 'package:vilsa/features/home/viewmodel/home_view_model.dart';
import 'package:vilsa/features/stock/model/stock_model.dart';
import 'package:vilsa/features/stock/viewmodel/stock_view_model.dart';

class AddStockView extends StatelessWidget {
  final StockModel? stock;

  const AddStockView({super.key, this.stock});

  @override
  Widget build(BuildContext context) {
    // Set up edit mode if stock is provided
    if (stock != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<StockViewModel>(context, listen: false).setupForEdit(stock!);
      });
    }

    return Scaffold(
      appBar: _buildAppBar(context),
      body: Consumer<StockViewModel>(
        builder: (context, viewModel, child) {
          return SafeArea(
            child: _buildAddForm(viewModel, context),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: context.primary,
      leading: IconButton(
        icon: Icon(Icons.chevron_left, color: context.onPrimary),
        onPressed: () {
          // Clear edit state before popping
          Provider.of<StockViewModel>(context, listen: false).clearEditState();
          Navigator.pop(context);
        },
      ),
      centerTitle: true,
      title: Consumer<StockViewModel>(
        builder: (context, viewModel, child) {
          return Highlight(
            text: viewModel.isEditing ? 'Düzenle' : 'Ekle',
            color: Colors.white,
          );
        },
      ),
    );
  }

  Widget _buildAddForm(StockViewModel viewModel, BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: _buildFormFields(viewModel, context),
          ),
        ),
        _buildButton(context, viewModel),
      ],
    );
  }

  Widget _buildFormFields(StockViewModel viewModel, BuildContext context) {
    FocusNode nameFocusNode = FocusNode();
    FocusNode abbreviationFocusNode = FocusNode();
    FocusNode dividendsFocusNode = FocusNode();

    return Padding(
      padding: PaddingConstants.pagePadding,
      child: Column(
        spacing: 16,
        children: [
          _buildNameField(viewModel, context, nameFocusNode, abbreviationFocusNode),
          _buildAbbreviationField(viewModel, context, abbreviationFocusNode, dividendsFocusNode),
          _buildDividendsField(viewModel, context, dividendsFocusNode),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, StockViewModel viewModel) {
    return Padding(
      padding: PaddingConstants.symmetricHorizontalMedium + PaddingConstants.onlyBottomMedium,
      child: viewModel.isLoading
          ? const CircularProgressIndicator()
          : GeneralButton(
              onPressed: () {
                if (viewModel.nameController.text.isEmpty) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => SuccessDialog(
                      message: 'Lütfen hisse adı alanını doldurun!',
                      icon: Icons.error_outline_rounded,
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                if (viewModel.abbreviationController.text.isEmpty) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => SuccessDialog(
                      message: 'Lütfen hisse kısaltması alanını doldurun!',
                      icon: Icons.error_outline_rounded,
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                // Temettü alanının boş olmasını engelleyelim, 0 girilebilir
                final dividendsText = viewModel.dividendsController.text;
                if (dividendsText.isEmpty) {
                  // Eğer boşsa 0 olarak ayarlayalım
                  viewModel.dividendsController.text = "0";
                } else {
                  // CurrencyInputFormatter, sayıyı "₺1.234,56" formatında gösterir
                  // Bunu parse ederken önce para birimi sembolünü kaldırmalı,
                  // sonra binlik ayırıcıları kaldırmalı, ve virgülü noktaya çevirmeliyiz
                  String normalizedText = dividendsText
                      .replaceAll('₺', '') // TL sembolünü kaldır
                      .replaceAll('.', '') // Binlik ayraçları kaldır
                      .trim() // Boşlukları kaldır
                      .replaceAll(',', '.'); // Virgülü nokta ile değiştir

                  print("DEBUG VIEW: Normalize edilmiş temettü metni: '$normalizedText'");

                  double? dividendValue;
                  try {
                    dividendValue = double.parse(normalizedText);
                    print("DEBUG VIEW: Parse edilen temettü değeri: $dividendValue");
                  } catch (e) {
                    print("DEBUG VIEW: Parse hatası: $e");
                    dividendValue = null;
                  }

                  if (dividendValue == null) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => SuccessDialog(
                        message: 'Temettü değeri geçerli bir sayı değil!',
                        icon: Icons.error_outline_rounded,
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }

                  if (dividendValue < 0) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => SuccessDialog(
                        message: 'Temettü değeri negatif olamaz!',
                        icon: Icons.error_outline_rounded,
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }
                }

                viewModel.addStock(context).then((result) {
                  if (result['success']) {
                    // Başarı dialogunu doğrudan mevcut context'te göster
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (dialogContext) => SuccessDialog(
                        message: result['operation'] == 'güncelleme'
                            ? '${viewModel.nameController.text} (${viewModel.abbreviationController.text}) hissesi başarıyla güncellendi!'
                            : '${viewModel.nameController.text} (${viewModel.abbreviationController.text}) hissesi portföyünüze başarıyla eklendi!',
                        backgroundColor: AppColors.dividendGreen,
                        icon: Icons.check_circle_outline_rounded,
                        iconColor: Colors.white,
                      ),
                    );

                    // Refresh the stocks list in all related ViewModels
                    try {
                      print("DEBUG VIEW: StockViewModel.fetchStocks çağrılıyor");
                      Provider.of<StockViewModel>(context, listen: false).fetchStocks();
                    } catch (e) {
                      print('DEBUG VIEW ERROR: StockViewModel güncellenemedi: $e');
                    }

                    try {
                      print("DEBUG VIEW: HomeViewModel.fetchStocks çağrılıyor");
                      Provider.of<HomeViewModel>(context, listen: false).fetchStocks();
                    } catch (e) {
                      print('DEBUG VIEW ERROR: HomeViewModel güncellenemedi: $e');
                    }

                    // Dialog gösterdikten sonra bekleme süresi
                    print("DEBUG VIEW: Navigator.pop için Future.delayed başlatılıyor");
                    Future.delayed(const Duration(milliseconds: 1500), () {
                      print("DEBUG VIEW: İlk Future.delayed tamamlandı, Dialog kapatılıyor");
                      // Önce dialog'u kapat
                      Navigator.of(context).pop();

                      // Kısa bir bekleme sonrası ana sayfaya dön
                      Future.delayed(const Duration(milliseconds: 100), () {
                        print("DEBUG VIEW: İkinci Future.delayed tamamlandı, Ana sayfaya dönülüyor");
                        Navigator.of(context).pop();
                      });
                    });
                  } else {
                    // Başarısız olursa hata dialogu göster
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => SuccessDialog(
                        message: 'Hisse kaydedilemedi!',
                        icon: Icons.error_outline_rounded,
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }).catchError((error) {
                  print("DEBUG VIEW ERROR: addStock hatası: $error");

                  // Hata durumunda dialog göster
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => SuccessDialog(
                      message: 'Bir hata oluştu: ${error.toString()}',
                      icon: Icons.error_outline_rounded,
                      backgroundColor: AppColors.error,
                    ),
                  );
                });
              },
              text: viewModel.isEditing ? 'Güncelle' : 'Ekle',
              textColor: context.onPrimary,
              backgroundColor: context.primary,
            ),
    );
  }

  Widget _buildNameField(
      StockViewModel viewModel, BuildContext context, FocusNode nameFocusNode, FocusNode abbreviationFocusNode) {
    return TextField(
      controller: viewModel.nameController,
      focusNode: nameFocusNode,
      decoration: const InputDecoration(labelText: 'Hisse Adı Girin'),
      onSubmitted: (_) {
        FocusScope.of(context).requestFocus(abbreviationFocusNode);
      },
    );
  }

  Widget _buildAbbreviationField(
      StockViewModel viewModel, BuildContext context, FocusNode abbreviationFocusNode, FocusNode dividendsFocusNode) {
    return TextField(
      controller: viewModel.abbreviationController,
      focusNode: abbreviationFocusNode,
      decoration: const InputDecoration(labelText: 'Hisse Kısaltmasını Girin'),
      onSubmitted: (_) {
        FocusScope.of(context).requestFocus(dividendsFocusNode);
      },
    );
  }

  Widget _buildDividendsField(StockViewModel viewModel, BuildContext context, FocusNode dividendsFocusNode) {
    return TextField(
      controller: viewModel.dividendsController,
      focusNode: dividendsFocusNode,
      decoration: const InputDecoration(labelText: 'Temettü Miktarını Girin (örn: 0,50)'),
      keyboardType: TextInputType.number,
      inputFormatters: [CurrencyInputFormatter()],
      onSubmitted: (_) {
        FocusScope.of(context).unfocus(); // Dismiss the keyboard
      },
    );
  }
}
