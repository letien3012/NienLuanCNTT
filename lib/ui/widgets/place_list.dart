import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PlaceList extends StatelessWidget {
  const PlaceList({super.key, required this.imageUrl, required this.address, required this.title, required this.price,this.ontap});
  final String imageUrl;
  final String address;
  final String title;
  final double price;
  final Function()? ontap;
  String formatPrice(double price) {
    if (price >= 1000000) {
      return NumberFormat().format(price / 1000000) + ' triệu';
    } else if (price >= 1000) {
      return NumberFormat().format(price / 1000) + ' nghìn';
    } else {
      return NumberFormat().format(price);
    }
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 110,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              image: DecorationImage(image: NetworkImage(imageUrl),
              fit: BoxFit.cover
            )
            ),
          ),
          Align(alignment: Alignment.centerLeft,child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold,), maxLines: 1,),),         
          Row(
            children: [
              const Icon(Icons.location_pin),
              const SizedBox(width: 5,),
              Flexible(child: Text(address, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w300), maxLines: 1,)),
            ],
          ),
          Align(alignment: Alignment.centerLeft,child: Text("Giá thuê: ${formatPrice(price)}", maxLines: 1,),)
        ],
      ),
    );
  }
}