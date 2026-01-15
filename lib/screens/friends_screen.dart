import 'package:flutter/material.dart';
import '../utils/command.dart';
import '../viewmodels/friend_viewmodel.dart';
import '../models/friend.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({
    super.key,
    required this.title,
    required this.viewModel,
  });

  final String title;
  final FriendViewModel viewModel;

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  @override
  Widget build(BuildContext context) {
    bool isPortrait = MediaQuery.sizeOf(context).height > MediaQuery.sizeOf(context).width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([
          widget.viewModel,
          widget.viewModel.load,
          widget.viewModel.addFriend,
          widget.viewModel.removeFriend,
        ]),
        builder: (context, child) {
          if (isPortrait) {
            return FriendList(viewModel: widget.viewModel, isPortrait: isPortrait);
          } else {
            return Row(
              children: [
                Expanded(
                  child: FriendList(viewModel: widget.viewModel, isPortrait: isPortrait),
                ),
                Expanded(
                  child: widget.viewModel.selectedFriend != null
                      ? FriendDetailsCard(friend: widget.viewModel.selectedFriend!)
                      : const Center(child: Text("Selecciona un amigo")),
                ),
              ],
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => FriendDialog(viewModel: widget.viewModel),
        ),
        tooltip: 'Agregar amigo',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class FriendList extends StatelessWidget {
  const FriendList({
    super.key,
    required this.viewModel,
    required this.isPortrait,
  });

  final FriendViewModel viewModel;
  final bool isPortrait;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (viewModel.load.running ||
            viewModel.addFriend.running ||
            viewModel.removeFriend.running)
          const Center(child: CircularProgressIndicator()),
        viewModel.friends.isEmpty
            ? const Center(child: Text("No hay amigos"))
            : CustomScrollView(
                slivers: [
                  if (viewModel.load.error ||
                      viewModel.addFriend.error ||
                      viewModel.removeFriend.error)
                    SliverToBoxAdapter(
                      child: InfoBar(
                        message: viewModel.errorMessage!,
                        onPressed: viewModel.load.error
                            ? viewModel.load.clearResult
                            : viewModel.addFriend.error
                                ? viewModel.addFriend.clearResult
                                : viewModel.removeFriend.clearResult,
                        isError: true,
                      ),
                    ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return FriendRow(
                          friend: viewModel.friends[index],
                          onTap: () => isPortrait
                              ? Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FriendDetailsScreen(
                                      friend: viewModel.friends[index],
                                    ),
                                  ),
                                )
                              : viewModel.setFriend(viewModel.friends[index]),
                          onRemove: viewModel.removeFriend,
                        );
                      },
                      childCount: viewModel.friends.length,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 200)),
                ],
              ),
      ],
    );
  }
}

class FriendRow extends StatelessWidget {
  const FriendRow({
    super.key,
    required this.friend,
    required this.onTap,
    required this.onRemove,
  });

  final Friend friend;
  final Command1 onRemove;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        key: ValueKey("friend-${friend.id}"),
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: CircleAvatar(child: Text(friend.name.substring(0, 1))),
          ),
          Expanded(
            child: InkWell(
              onTap: () => onTap(),
              child: Text(friend.name),
            ),
          ),
          IconButton(
            onPressed: () => onRemove.execute(friend.id!),
            icon: Icon(
              Icons.delete,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }
}

class InfoBar extends StatelessWidget {
  const InfoBar({
    super.key,
    required this.message,
    required this.onPressed,
    this.isError = false,
  });

  final String message;
  final Function onPressed;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isError
          ? Theme.of(context).colorScheme.errorContainer
          : Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              message,
              style: TextStyle(
                color: isError
                    ? Theme.of(context).colorScheme.onErrorContainer
                    : Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
            ElevatedButton(
              onPressed: () => onPressed(),
              style: ButtonStyle(
                foregroundColor: WidgetStatePropertyAll(
                  isError
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.secondary,
                ),
              ),
              child: const Text("Cerrar"),
            ),
          ],
        ),
      ),
    );
  }
}

class FriendDialog extends StatefulWidget {
  const FriendDialog({super.key, required this.viewModel});

  final FriendViewModel viewModel;

  @override
  State<StatefulWidget> createState() => _FriendDialogState();
}

class _FriendDialogState extends State<FriendDialog> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Agregar nuevo amigo"),
      content: Form(
        key: _formKey,
        child: TextFormField(
          decoration: const InputDecoration(
            icon: Icon(Icons.person),
            labelText: "Nombre",
          ),
          controller: nameController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Por favor ingresa un nombre";
            }
            return null;
          },
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context);
              widget.viewModel.addFriend.execute(nameController.text);
            }
          },
          child: const Text("Agregar"),
        ),
      ],
    );
  }
}

class FriendDetailsScreen extends StatelessWidget {
  const FriendDetailsScreen({super.key, required this.friend});

  final Friend friend;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalles del amigo"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: FriendDetailsCard(friend: friend),
    );
  }
}

class FriendDetailsCard extends StatelessWidget {
  const FriendDetailsCard({
    super.key,
    required this.friend,
  });

  final Friend friend;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 10,
        color: Theme.of(context).colorScheme.onPrimary,
        shadowColor: Colors.black,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: Text(friend.name),
                subtitle: const Text('Información del amigo'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.credit_score, color: Colors.green),
                title: const Text('Balance de crédito'),
                trailing: Text(
                  '€${friend.creditBalance?.toStringAsFixed(2) ?? '0.00'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 18,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.credit_card, color: Colors.red),
                title: const Text('Balance de débito'),
                trailing: Text(
                  '€${friend.debitBalance?.toStringAsFixed(2) ?? '0.00'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
