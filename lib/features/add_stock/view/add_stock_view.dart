import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vilsa/core/components/general_button.dart';
import 'package:vilsa/core/components/general_text.dart';
import 'package:vilsa/core/constants/padding_constants.dart';
import 'package:vilsa/core/extensions/context_extension.dart';
import 'package:vilsa/features/add_stock/model/stock_model.dart';
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
        _buildFormFields(viewModel, context),
        const Spacer(),
        _buildButton(context, viewModel),
      ],
    );
  }

  Widget _buildFormFields(StockViewModel viewModel, BuildContext context) {
    return Padding(
      padding: PaddingConstants.pagePadding,
      child: Column(
        spacing: 16,
        children: [
          _buildNameField(viewModel, context),
          _buildAbbreviationField(viewModel, context),
          _buildDividendsField(viewModel, context),
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.red,
                      content: Content(
                        text: 'Lütfen hisse adı alanını doldurun!',
                        isBold: true,
                        isCentred: true,
                      ),
                    ),
                  );
                  return;
                }

                if (viewModel.abbreviationController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.red,
                      content: Content(
                        text: 'Lütfen hisse kısaltması alanını doldurun!',
                        isBold: true,
                        isCentred: true,
                      ),
                    ),
                  );
                  return;
                }

                if (viewModel.dividendsController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.red,
                      content: Content(
                        text: 'Lütfen temettü miktarı alanını doldurun!',
                        isBold: true,
                        isCentred: true,
                      ),
                    ),
                  );
                  return;
                }

                viewModel.addStock(context);
                viewModel.fetchStocks();

                Navigator.pop(context);
              },
              text: viewModel.isEditing ? 'Güncelle' : 'Ekle',
              textColor: context.onPrimary,
              backgroundColor: context.primary,
            ),
    );
  }

  Widget _buildNameField(StockViewModel viewModel, BuildContext context) {
    return TextField(
      controller: viewModel.nameController,
      decoration: const InputDecoration(labelText: 'Hisse Adı Girin'),
    );
  }

  Widget _buildAbbreviationField(StockViewModel viewModel, BuildContext context) {
    return TextField(
      controller: viewModel.abbreviationController,
      decoration: const InputDecoration(labelText: 'Hisse Kısaltmasını Girin'),
    );
  }

  Widget _buildDividendsField(StockViewModel viewModel, BuildContext context) {
    return TextField(
      controller: viewModel.dividendsController,
      decoration: const InputDecoration(labelText: 'Temettü Miktarını Girin'),
      keyboardType: TextInputType.number,
    );
  }
}
// Updated on 2025-01-02 - add transaction history page
// Updated on 2025-01-31 - implement filtering options
// Updated on 2025-02-01 - improve button styling
// Updated on 2025-02-12 - address memory leaks
// Updated on 2025-02-19 - implement error handling
// Updated on 2025-02-27 - implement sorting options
// Updated on 2025-03-06 - optimize data fetching logic
// Updated on 2025-03-13 - correct data loading problems
// Updated on 2025-03-15 - improve loading indicator
// Updated on 2025-03-19 - enhance component reusability
// Updated on 2025-03-20 - add transaction history page
