import 'package:flutter/material.dart';
class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    this.actionText,
    this.onPressed,
  });

  final String? actionText;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        actionText ?? 'Okay',
        style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 24,
            ),
      ),
    );
  }
}
Future<void> showErrorDialog(BuildContext context, String message){
  return showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Center(child: Text('Thông báo', style: TextStyle(fontSize: 24, color: Colors.red, fontWeight: FontWeight.bold),)),
      content: Text(message+' Vui lòng thử lại', style: TextStyle(fontSize: 20), textAlign: TextAlign.center,),
      actions: [
        ActionButton(
          onPressed: (){
            Navigator.of(context).pop();
          },
        )
      ],
    )
  );
}


Future<bool?> showConfirmDialog(BuildContext context, String message) {
  return showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: const Icon(Icons.warning, color: Colors.yellow,),
      title: Text(message),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: ActionButton(
                actionText: 'No',
                onPressed: () {
                  Navigator.of(ctx).pop(false);
                },
              ),
            ),
            Expanded(
              child: ActionButton(
                actionText: 'Yes',
                onPressed: () {
                  Navigator.of(ctx).pop(true);
                },
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
