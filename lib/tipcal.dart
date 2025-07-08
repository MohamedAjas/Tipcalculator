import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    home: TipCalculator(),
  ));
}

class TipCalculator extends StatefulWidget {
  const TipCalculator({super.key});

  @override
  State<TipCalculator> createState() => _TipCalculatorState();
}

class _TipCalculatorState extends State<TipCalculator> {
  final TextEditingController _billController = TextEditingController();
  double _billAmount = 0.0;
  double _tipPercentage = 15.0;
  int _splitBy = 1;
  bool _roundTotal = false;
  String _currency = 'Rs.'; // Default currency

  // History of previous calculations
  List<String> _history = [];

  void _reset() {
    setState(() {
      _billController.clear();
      _billAmount = 0.0;
      _tipPercentage = 15.0;
      _splitBy = 1;
      _roundTotal = false;
    });
  }

  // Method to add the current calculation to the history
  void _addToHistory(double tipAmount, double totalAmount, double perPersonAmount) {
    if (_billAmount > 0) {
      setState(() {
        _history.insert(
          0,
          'Tip: ${tipAmount.toStringAsFixed(2)} | Total: ${totalAmount.toStringAsFixed(2)} | Per Person: ${perPersonAmount.toStringAsFixed(2)}',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double tipAmount = (_billAmount * _tipPercentage) / 100;
    double totalAmount = _billAmount + tipAmount;
    if (_roundTotal) {
      totalAmount = totalAmount.roundToDouble();
    }
    double perPersonAmount = totalAmount / _splitBy;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigoAccent,
        centerTitle: true,
        title: const Text(
          'TIP Calculator',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
        ),
      ),
      body: SingleChildScrollView( // Enables scrolling to prevent overflow
        child: Container(
          // Gradient background for a modern look
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade50, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bill Amount TextField
              _buildTextField('Bill Amount', _billController, TextInputType.number),
              const SizedBox(height: 20),
              // Tip Percentage Slider
              _buildTipSlider(),
              const SizedBox(height: 20),
              // Split By counter
              _buildSplitRow(),
              const SizedBox(height: 20),
              // Round Total Switch
              _buildRoundSwitch(),
              const SizedBox(height: 20),
              // Currency Selector Dropdown
              _buildCurrencySelector(),
              const SizedBox(height: 20),
              // Results Card with gradient design
              _buildResultsCard(tipAmount, totalAmount, perPersonAmount),
              const SizedBox(height: 20),
              // Calculate Button to save calculation and show history on next page
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _addToHistory(tipAmount, totalAmount, perPersonAmount);
                    // Navigate to the HistoryPage, passing the history list and a deletion callback
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HistoryPage(
                          history: _history,
                          onDelete: (index) {
                            setState(() {
                              _history.removeAt(index);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Data deleted')),
                            );
                          },
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  child: const Text(
                    'CALCULATION HISTORY',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Reset Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _reset,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigoAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  child: const Text(
                    'RESET',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build the Bill Amount input field with a white background
  Widget _buildTextField(String label, TextEditingController controller, TextInputType inputType) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.indigoAccent, fontWeight: FontWeight.w600),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      ),
      onChanged: (value) {
        setState(() {
          _billAmount = double.tryParse(value) ?? 0.0;
        });
      },
    );
  }

  // Build the Tip Percentage slider
  Widget _buildTipSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tip Percentage: ${_tipPercentage.toInt()}%',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.indigoAccent),
        ),
        Slider(
          value: _tipPercentage,
          min: 0,
          max: 100,
          divisions: 100,
          label: '${_tipPercentage.toInt()}%',
          activeColor: Colors.indigoAccent,
          inactiveColor: Colors.grey.shade400,
          onChanged: (value) {
            setState(() {
              _tipPercentage = value;
            });
          },
        ),
      ],
    );
  }

  // Build the Split By counter row
  Widget _buildSplitRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Split By: $_splitBy',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigoAccent),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
              onPressed: () {
                setState(() {
                  if (_splitBy > 1) _splitBy--;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.green),
              onPressed: () {
                setState(() {
                  _splitBy++;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  // Build the Round Total switch
  Widget _buildRoundSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Round Total',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigoAccent),
        ),
        Switch(
          value: _roundTotal,
          activeColor: Colors.indigoAccent,
          onChanged: (value) {
            setState(() {
              _roundTotal = value;
            });
          },
        ),
      ],
    );
  }

  // Build the Currency Selector dropdown
  Widget _buildCurrencySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Currency',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigoAccent),
        ),
        DropdownButton<String>(
          value: _currency,
          onChanged: (newCurrency) {
            setState(() {
              _currency = newCurrency!;
            });
          },
          items: ['Rs.', '\$', '€', '£'].map((currency) {
            return DropdownMenuItem<String>(
              value: currency,
              child: Text(currency, style: const TextStyle(fontWeight: FontWeight.bold)),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Build the Results Card with a gradient design
  Widget _buildResultsCard(double tipAmount, double totalAmount, double perPersonAmount) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade100, Colors.indigo.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildResultRow("Tip Amount:", "$_currency${tipAmount.toStringAsFixed(2)}"),
            const SizedBox(height: 8),
            _buildResultRow("Total Amount:", "$_currency${totalAmount.toStringAsFixed(2)}"),
            const SizedBox(height: 8),
            _buildResultRow("Per Person:", "$_currency${perPersonAmount.toStringAsFixed(2)}"),
          ],
        ),
      ),
    );
  }

  // Build a single result row
  Widget _buildResultRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.indigoAccent),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigoAccent),
        ),
      ],
    );
  }
}

// New HistoryPage to show saved calculations with a delete button
class HistoryPage extends StatefulWidget {
  final List<String> history;
  final Function(int) onDelete;

  const HistoryPage({Key? key, required this.history, required this.onDelete}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculation History'),
        backgroundColor: Colors.indigoAccent,
      ),
      body: widget.history.isEmpty
          ? const Center(
        child: Text(
          'No history found',
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        itemCount: widget.history.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              title: Text(widget.history[index]),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  widget.onDelete(index);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Data deleted')),
                  );
                  setState(() {}); // Refresh list if needed
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
