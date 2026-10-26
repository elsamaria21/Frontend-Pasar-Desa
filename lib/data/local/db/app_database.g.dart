part of 'app_database.dart';

class $ProductsTableTable extends ProductsTable
    with TableInfo<$ProductsTableTable, ProductEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _shortNameMeta =
      const VerificationMeta('shortName');
  @override
  late final GeneratedColumn<String> shortName = GeneratedColumn<String>(
      'short_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sellerMeta = const VerificationMeta('seller');
  @override
  late final GeneratedColumn<String> seller = GeneratedColumn<String>(
      'seller', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<int> price = GeneratedColumn<int>(
      'price', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _imageMeta = const VerificationMeta('image');
  @override
  late final GeneratedColumn<String> image = GeneratedColumn<String>(
      'image', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<double> rating = GeneratedColumn<double>(
      'rating', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _stockMeta = const VerificationMeta('stock');
  @override
  late final GeneratedColumn<int> stock = GeneratedColumn<int>(
      'stock', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _lastFetchedMeta =
      const VerificationMeta('lastFetched');
  @override
  late final GeneratedColumn<int> lastFetched = GeneratedColumn<int>(
      'last_fetched', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        shortName,
        seller,
        category,
        price,
        unit,
        image,
        rating,
        stock,
        lastFetched
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products_table';
  @override
  VerificationContext validateIntegrity(Insertable<ProductEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('short_name')) {
      context.handle(_shortNameMeta,
          shortName.isAcceptableOrUnknown(data['short_name']!, _shortNameMeta));
    } else if (isInserting) {
      context.missing(_shortNameMeta);
    }
    if (data.containsKey('seller')) {
      context.handle(_sellerMeta,
          seller.isAcceptableOrUnknown(data['seller']!, _sellerMeta));
    } else if (isInserting) {
      context.missing(_sellerMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('price')) {
      context.handle(
          _priceMeta, price.isAcceptableOrUnknown(data['price']!, _priceMeta));
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('image')) {
      context.handle(
          _imageMeta, image.isAcceptableOrUnknown(data['image']!, _imageMeta));
    } else if (isInserting) {
      context.missing(_imageMeta);
    }
    if (data.containsKey('rating')) {
      context.handle(_ratingMeta,
          rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta));
    } else if (isInserting) {
      context.missing(_ratingMeta);
    }
    if (data.containsKey('stock')) {
      context.handle(
          _stockMeta, stock.isAcceptableOrUnknown(data['stock']!, _stockMeta));
    } else if (isInserting) {
      context.missing(_stockMeta);
    }
    if (data.containsKey('last_fetched')) {
      context.handle(
          _lastFetchedMeta,
          lastFetched.isAcceptableOrUnknown(
              data['last_fetched']!, _lastFetchedMeta));
    } else if (isInserting) {
      context.missing(_lastFetchedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      shortName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}short_name'])!,
      seller: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}seller'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      price: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}price'])!,
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit'])!,
      image: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image'])!,
      rating: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}rating'])!,
      stock: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}stock'])!,
      lastFetched: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_fetched'])!,
    );
  }

  @override
  $ProductsTableTable createAlias(String alias) {
    return $ProductsTableTable(attachedDatabase, alias);
  }
}

class ProductEntry extends DataClass implements Insertable<ProductEntry> {
  final String id;
  final String name;
  final String shortName;
  final String seller;
  final String category;
  final int price;
  final String unit;
  final String image;
  final double rating;
  final int stock;

  final int lastFetched;
  const ProductEntry(
      {required this.id,
      required this.name,
      required this.shortName,
      required this.seller,
      required this.category,
      required this.price,
      required this.unit,
      required this.image,
      required this.rating,
      required this.stock,
      required this.lastFetched});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['short_name'] = Variable<String>(shortName);
    map['seller'] = Variable<String>(seller);
    map['category'] = Variable<String>(category);
    map['price'] = Variable<int>(price);
    map['unit'] = Variable<String>(unit);
    map['image'] = Variable<String>(image);
    map['rating'] = Variable<double>(rating);
    map['stock'] = Variable<int>(stock);
    map['last_fetched'] = Variable<int>(lastFetched);
    return map;
  }

  ProductsTableCompanion toCompanion(bool nullToAbsent) {
    return ProductsTableCompanion(
      id: Value(id),
      name: Value(name),
      shortName: Value(shortName),
      seller: Value(seller),
      category: Value(category),
      price: Value(price),
      unit: Value(unit),
      image: Value(image),
      rating: Value(rating),
      stock: Value(stock),
      lastFetched: Value(lastFetched),
    );
  }

  factory ProductEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductEntry(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      shortName: serializer.fromJson<String>(json['shortName']),
      seller: serializer.fromJson<String>(json['seller']),
      category: serializer.fromJson<String>(json['category']),
      price: serializer.fromJson<int>(json['price']),
      unit: serializer.fromJson<String>(json['unit']),
      image: serializer.fromJson<String>(json['image']),
      rating: serializer.fromJson<double>(json['rating']),
      stock: serializer.fromJson<int>(json['stock']),
      lastFetched: serializer.fromJson<int>(json['lastFetched']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'shortName': serializer.toJson<String>(shortName),
      'seller': serializer.toJson<String>(seller),
      'category': serializer.toJson<String>(category),
      'price': serializer.toJson<int>(price),
      'unit': serializer.toJson<String>(unit),
      'image': serializer.toJson<String>(image),
      'rating': serializer.toJson<double>(rating),
      'stock': serializer.toJson<int>(stock),
      'lastFetched': serializer.toJson<int>(lastFetched),
    };
  }

  ProductEntry copyWith(
          {String? id,
          String? name,
          String? shortName,
          String? seller,
          String? category,
          int? price,
          String? unit,
          String? image,
          double? rating,
          int? stock,
          int? lastFetched}) =>
      ProductEntry(
        id: id ?? this.id,
        name: name ?? this.name,
        shortName: shortName ?? this.shortName,
        seller: seller ?? this.seller,
        category: category ?? this.category,
        price: price ?? this.price,
        unit: unit ?? this.unit,
        image: image ?? this.image,
        rating: rating ?? this.rating,
        stock: stock ?? this.stock,
        lastFetched: lastFetched ?? this.lastFetched,
      );
  ProductEntry copyWithCompanion(ProductsTableCompanion data) {
    return ProductEntry(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      shortName: data.shortName.present ? data.shortName.value : this.shortName,
      seller: data.seller.present ? data.seller.value : this.seller,
      category: data.category.present ? data.category.value : this.category,
      price: data.price.present ? data.price.value : this.price,
      unit: data.unit.present ? data.unit.value : this.unit,
      image: data.image.present ? data.image.value : this.image,
      rating: data.rating.present ? data.rating.value : this.rating,
      stock: data.stock.present ? data.stock.value : this.stock,
      lastFetched:
          data.lastFetched.present ? data.lastFetched.value : this.lastFetched,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductEntry(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('shortName: $shortName, ')
          ..write('seller: $seller, ')
          ..write('category: $category, ')
          ..write('price: $price, ')
          ..write('unit: $unit, ')
          ..write('image: $image, ')
          ..write('rating: $rating, ')
          ..write('stock: $stock, ')
          ..write('lastFetched: $lastFetched')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, shortName, seller, category, price,
      unit, image, rating, stock, lastFetched);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductEntry &&
          other.id == this.id &&
          other.name == this.name &&
          other.shortName == this.shortName &&
          other.seller == this.seller &&
          other.category == this.category &&
          other.price == this.price &&
          other.unit == this.unit &&
          other.image == this.image &&
          other.rating == this.rating &&
          other.stock == this.stock &&
          other.lastFetched == this.lastFetched);
}

class ProductsTableCompanion extends UpdateCompanion<ProductEntry> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> shortName;
  final Value<String> seller;
  final Value<String> category;
  final Value<int> price;
  final Value<String> unit;
  final Value<String> image;
  final Value<double> rating;
  final Value<int> stock;
  final Value<int> lastFetched;
  final Value<int> rowid;
  const ProductsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.shortName = const Value.absent(),
    this.seller = const Value.absent(),
    this.category = const Value.absent(),
    this.price = const Value.absent(),
    this.unit = const Value.absent(),
    this.image = const Value.absent(),
    this.rating = const Value.absent(),
    this.stock = const Value.absent(),
    this.lastFetched = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductsTableCompanion.insert({
    required String id,
    required String name,
    required String shortName,
    required String seller,
    required String category,
    required int price,
    required String unit,
    required String image,
    required double rating,
    required int stock,
    required int lastFetched,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        shortName = Value(shortName),
        seller = Value(seller),
        category = Value(category),
        price = Value(price),
        unit = Value(unit),
        image = Value(image),
        rating = Value(rating),
        stock = Value(stock),
        lastFetched = Value(lastFetched);
  static Insertable<ProductEntry> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? shortName,
    Expression<String>? seller,
    Expression<String>? category,
    Expression<int>? price,
    Expression<String>? unit,
    Expression<String>? image,
    Expression<double>? rating,
    Expression<int>? stock,
    Expression<int>? lastFetched,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (shortName != null) 'short_name': shortName,
      if (seller != null) 'seller': seller,
      if (category != null) 'category': category,
      if (price != null) 'price': price,
      if (unit != null) 'unit': unit,
      if (image != null) 'image': image,
      if (rating != null) 'rating': rating,
      if (stock != null) 'stock': stock,
      if (lastFetched != null) 'last_fetched': lastFetched,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? shortName,
      Value<String>? seller,
      Value<String>? category,
      Value<int>? price,
      Value<String>? unit,
      Value<String>? image,
      Value<double>? rating,
      Value<int>? stock,
      Value<int>? lastFetched,
      Value<int>? rowid}) {
    return ProductsTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      seller: seller ?? this.seller,
      category: category ?? this.category,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      image: image ?? this.image,
      rating: rating ?? this.rating,
      stock: stock ?? this.stock,
      lastFetched: lastFetched ?? this.lastFetched,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (shortName.present) {
      map['short_name'] = Variable<String>(shortName.value);
    }
    if (seller.present) {
      map['seller'] = Variable<String>(seller.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (price.present) {
      map['price'] = Variable<int>(price.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (image.present) {
      map['image'] = Variable<String>(image.value);
    }
    if (rating.present) {
      map['rating'] = Variable<double>(rating.value);
    }
    if (stock.present) {
      map['stock'] = Variable<int>(stock.value);
    }
    if (lastFetched.present) {
      map['last_fetched'] = Variable<int>(lastFetched.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('shortName: $shortName, ')
          ..write('seller: $seller, ')
          ..write('category: $category, ')
          ..write('price: $price, ')
          ..write('unit: $unit, ')
          ..write('image: $image, ')
          ..write('rating: $rating, ')
          ..write('stock: $stock, ')
          ..write('lastFetched: $lastFetched, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OrdersTableTable extends OrdersTable
    with TableInfo<$OrdersTableTable, DbOrder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrdersTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sellerMeta = const VerificationMeta('seller');
  @override
  late final GeneratedColumn<String> seller = GeneratedColumn<String>(
      'seller', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateLabelMeta =
      const VerificationMeta('dateLabel');
  @override
  late final GeneratedColumn<String> dateLabel = GeneratedColumn<String>(
      'date_label', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<int> total = GeneratedColumn<int>(
      'total', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _paymentLabelMeta =
      const VerificationMeta('paymentLabel');
  @override
  late final GeneratedColumn<String> paymentLabel = GeneratedColumn<String>(
      'payment_label', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _courierTitleMeta =
      const VerificationMeta('courierTitle');
  @override
  late final GeneratedColumn<String> courierTitle = GeneratedColumn<String>(
      'courier_title', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _courierInfoMeta =
      const VerificationMeta('courierInfo');
  @override
  late final GeneratedColumn<String> courierInfo = GeneratedColumn<String>(
      'courier_info', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _receiverNameMeta =
      const VerificationMeta('receiverName');
  @override
  late final GeneratedColumn<String> receiverName = GeneratedColumn<String>(
      'receiver_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _receiverPhoneMeta =
      const VerificationMeta('receiverPhone');
  @override
  late final GeneratedColumn<String> receiverPhone = GeneratedColumn<String>(
      'receiver_phone', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _deliveryAddressMeta =
      const VerificationMeta('deliveryAddress');
  @override
  late final GeneratedColumn<String> deliveryAddress = GeneratedColumn<String>(
      'delivery_address', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _deliveryNoteMeta =
      const VerificationMeta('deliveryNote');
  @override
  late final GeneratedColumn<String> deliveryNote = GeneratedColumn<String>(
      'delivery_note', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        seller,
        dateLabel,
        status,
        total,
        paymentLabel,
        courierTitle,
        courierInfo,
        receiverName,
        receiverPhone,
        deliveryAddress,
        deliveryNote,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'orders_table';
  @override
  VerificationContext validateIntegrity(Insertable<DbOrder> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('seller')) {
      context.handle(_sellerMeta,
          seller.isAcceptableOrUnknown(data['seller']!, _sellerMeta));
    } else if (isInserting) {
      context.missing(_sellerMeta);
    }
    if (data.containsKey('date_label')) {
      context.handle(_dateLabelMeta,
          dateLabel.isAcceptableOrUnknown(data['date_label']!, _dateLabelMeta));
    } else if (isInserting) {
      context.missing(_dateLabelMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('total')) {
      context.handle(
          _totalMeta, total.isAcceptableOrUnknown(data['total']!, _totalMeta));
    } else if (isInserting) {
      context.missing(_totalMeta);
    }
    if (data.containsKey('payment_label')) {
      context.handle(
          _paymentLabelMeta,
          paymentLabel.isAcceptableOrUnknown(
              data['payment_label']!, _paymentLabelMeta));
    } else if (isInserting) {
      context.missing(_paymentLabelMeta);
    }
    if (data.containsKey('courier_title')) {
      context.handle(
          _courierTitleMeta,
          courierTitle.isAcceptableOrUnknown(
              data['courier_title']!, _courierTitleMeta));
    }
    if (data.containsKey('courier_info')) {
      context.handle(
          _courierInfoMeta,
          courierInfo.isAcceptableOrUnknown(
              data['courier_info']!, _courierInfoMeta));
    }
    if (data.containsKey('receiver_name')) {
      context.handle(
          _receiverNameMeta,
          receiverName.isAcceptableOrUnknown(
              data['receiver_name']!, _receiverNameMeta));
    } else if (isInserting) {
      context.missing(_receiverNameMeta);
    }
    if (data.containsKey('receiver_phone')) {
      context.handle(
          _receiverPhoneMeta,
          receiverPhone.isAcceptableOrUnknown(
              data['receiver_phone']!, _receiverPhoneMeta));
    } else if (isInserting) {
      context.missing(_receiverPhoneMeta);
    }
    if (data.containsKey('delivery_address')) {
      context.handle(
          _deliveryAddressMeta,
          deliveryAddress.isAcceptableOrUnknown(
              data['delivery_address']!, _deliveryAddressMeta));
    } else if (isInserting) {
      context.missing(_deliveryAddressMeta);
    }
    if (data.containsKey('delivery_note')) {
      context.handle(
          _deliveryNoteMeta,
          deliveryNote.isAcceptableOrUnknown(
              data['delivery_note']!, _deliveryNoteMeta));
    } else if (isInserting) {
      context.missing(_deliveryNoteMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbOrder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbOrder(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      seller: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}seller'])!,
      dateLabel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date_label'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      total: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total'])!,
      paymentLabel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payment_label'])!,
      courierTitle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}courier_title']),
      courierInfo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}courier_info']),
      receiverName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}receiver_name'])!,
      receiverPhone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}receiver_phone'])!,
      deliveryAddress: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}delivery_address'])!,
      deliveryNote: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}delivery_note'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $OrdersTableTable createAlias(String alias) {
    return $OrdersTableTable(attachedDatabase, alias);
  }
}

class DbOrder extends DataClass implements Insertable<DbOrder> {
  final String id;
  final String seller;
  final String dateLabel;
  final String status;
  final int total;
  final String paymentLabel;
  final String? courierTitle;
  final String? courierInfo;
  final String receiverName;
  final String receiverPhone;
  final String deliveryAddress;
  final String deliveryNote;
  final int createdAt;
  const DbOrder(
      {required this.id,
      required this.seller,
      required this.dateLabel,
      required this.status,
      required this.total,
      required this.paymentLabel,
      this.courierTitle,
      this.courierInfo,
      required this.receiverName,
      required this.receiverPhone,
      required this.deliveryAddress,
      required this.deliveryNote,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['seller'] = Variable<String>(seller);
    map['date_label'] = Variable<String>(dateLabel);
    map['status'] = Variable<String>(status);
    map['total'] = Variable<int>(total);
    map['payment_label'] = Variable<String>(paymentLabel);
    if (!nullToAbsent || courierTitle != null) {
      map['courier_title'] = Variable<String>(courierTitle);
    }
    if (!nullToAbsent || courierInfo != null) {
      map['courier_info'] = Variable<String>(courierInfo);
    }
    map['receiver_name'] = Variable<String>(receiverName);
    map['receiver_phone'] = Variable<String>(receiverPhone);
    map['delivery_address'] = Variable<String>(deliveryAddress);
    map['delivery_note'] = Variable<String>(deliveryNote);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  OrdersTableCompanion toCompanion(bool nullToAbsent) {
    return OrdersTableCompanion(
      id: Value(id),
      seller: Value(seller),
      dateLabel: Value(dateLabel),
      status: Value(status),
      total: Value(total),
      paymentLabel: Value(paymentLabel),
      courierTitle: courierTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(courierTitle),
      courierInfo: courierInfo == null && nullToAbsent
          ? const Value.absent()
          : Value(courierInfo),
      receiverName: Value(receiverName),
      receiverPhone: Value(receiverPhone),
      deliveryAddress: Value(deliveryAddress),
      deliveryNote: Value(deliveryNote),
      createdAt: Value(createdAt),
    );
  }

  factory DbOrder.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbOrder(
      id: serializer.fromJson<String>(json['id']),
      seller: serializer.fromJson<String>(json['seller']),
      dateLabel: serializer.fromJson<String>(json['dateLabel']),
      status: serializer.fromJson<String>(json['status']),
      total: serializer.fromJson<int>(json['total']),
      paymentLabel: serializer.fromJson<String>(json['paymentLabel']),
      courierTitle: serializer.fromJson<String?>(json['courierTitle']),
      courierInfo: serializer.fromJson<String?>(json['courierInfo']),
      receiverName: serializer.fromJson<String>(json['receiverName']),
      receiverPhone: serializer.fromJson<String>(json['receiverPhone']),
      deliveryAddress: serializer.fromJson<String>(json['deliveryAddress']),
      deliveryNote: serializer.fromJson<String>(json['deliveryNote']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'seller': serializer.toJson<String>(seller),
      'dateLabel': serializer.toJson<String>(dateLabel),
      'status': serializer.toJson<String>(status),
      'total': serializer.toJson<int>(total),
      'paymentLabel': serializer.toJson<String>(paymentLabel),
      'courierTitle': serializer.toJson<String?>(courierTitle),
      'courierInfo': serializer.toJson<String?>(courierInfo),
      'receiverName': serializer.toJson<String>(receiverName),
      'receiverPhone': serializer.toJson<String>(receiverPhone),
      'deliveryAddress': serializer.toJson<String>(deliveryAddress),
      'deliveryNote': serializer.toJson<String>(deliveryNote),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  DbOrder copyWith(
          {String? id,
          String? seller,
          String? dateLabel,
          String? status,
          int? total,
          String? paymentLabel,
          Value<String?> courierTitle = const Value.absent(),
          Value<String?> courierInfo = const Value.absent(),
          String? receiverName,
          String? receiverPhone,
          String? deliveryAddress,
          String? deliveryNote,
          int? createdAt}) =>
      DbOrder(
        id: id ?? this.id,
        seller: seller ?? this.seller,
        dateLabel: dateLabel ?? this.dateLabel,
        status: status ?? this.status,
        total: total ?? this.total,
        paymentLabel: paymentLabel ?? this.paymentLabel,
        courierTitle:
            courierTitle.present ? courierTitle.value : this.courierTitle,
        courierInfo: courierInfo.present ? courierInfo.value : this.courierInfo,
        receiverName: receiverName ?? this.receiverName,
        receiverPhone: receiverPhone ?? this.receiverPhone,
        deliveryAddress: deliveryAddress ?? this.deliveryAddress,
        deliveryNote: deliveryNote ?? this.deliveryNote,
        createdAt: createdAt ?? this.createdAt,
      );
  DbOrder copyWithCompanion(OrdersTableCompanion data) {
    return DbOrder(
      id: data.id.present ? data.id.value : this.id,
      seller: data.seller.present ? data.seller.value : this.seller,
      dateLabel: data.dateLabel.present ? data.dateLabel.value : this.dateLabel,
      status: data.status.present ? data.status.value : this.status,
      total: data.total.present ? data.total.value : this.total,
      paymentLabel: data.paymentLabel.present
          ? data.paymentLabel.value
          : this.paymentLabel,
      courierTitle: data.courierTitle.present
          ? data.courierTitle.value
          : this.courierTitle,
      courierInfo:
          data.courierInfo.present ? data.courierInfo.value : this.courierInfo,
      receiverName: data.receiverName.present
          ? data.receiverName.value
          : this.receiverName,
      receiverPhone: data.receiverPhone.present
          ? data.receiverPhone.value
          : this.receiverPhone,
      deliveryAddress: data.deliveryAddress.present
          ? data.deliveryAddress.value
          : this.deliveryAddress,
      deliveryNote: data.deliveryNote.present
          ? data.deliveryNote.value
          : this.deliveryNote,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbOrder(')
          ..write('id: $id, ')
          ..write('seller: $seller, ')
          ..write('dateLabel: $dateLabel, ')
          ..write('status: $status, ')
          ..write('total: $total, ')
          ..write('paymentLabel: $paymentLabel, ')
          ..write('courierTitle: $courierTitle, ')
          ..write('courierInfo: $courierInfo, ')
          ..write('receiverName: $receiverName, ')
          ..write('receiverPhone: $receiverPhone, ')
          ..write('deliveryAddress: $deliveryAddress, ')
          ..write('deliveryNote: $deliveryNote, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      seller,
      dateLabel,
      status,
      total,
      paymentLabel,
      courierTitle,
      courierInfo,
      receiverName,
      receiverPhone,
      deliveryAddress,
      deliveryNote,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbOrder &&
          other.id == this.id &&
          other.seller == this.seller &&
          other.dateLabel == this.dateLabel &&
          other.status == this.status &&
          other.total == this.total &&
          other.paymentLabel == this.paymentLabel &&
          other.courierTitle == this.courierTitle &&
          other.courierInfo == this.courierInfo &&
          other.receiverName == this.receiverName &&
          other.receiverPhone == this.receiverPhone &&
          other.deliveryAddress == this.deliveryAddress &&
          other.deliveryNote == this.deliveryNote &&
          other.createdAt == this.createdAt);
}

class OrdersTableCompanion extends UpdateCompanion<DbOrder> {
  final Value<String> id;
  final Value<String> seller;
  final Value<String> dateLabel;
  final Value<String> status;
  final Value<int> total;
  final Value<String> paymentLabel;
  final Value<String?> courierTitle;
  final Value<String?> courierInfo;
  final Value<String> receiverName;
  final Value<String> receiverPhone;
  final Value<String> deliveryAddress;
  final Value<String> deliveryNote;
  final Value<int> createdAt;
  final Value<int> rowid;
  const OrdersTableCompanion({
    this.id = const Value.absent(),
    this.seller = const Value.absent(),
    this.dateLabel = const Value.absent(),
    this.status = const Value.absent(),
    this.total = const Value.absent(),
    this.paymentLabel = const Value.absent(),
    this.courierTitle = const Value.absent(),
    this.courierInfo = const Value.absent(),
    this.receiverName = const Value.absent(),
    this.receiverPhone = const Value.absent(),
    this.deliveryAddress = const Value.absent(),
    this.deliveryNote = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OrdersTableCompanion.insert({
    required String id,
    required String seller,
    required String dateLabel,
    required String status,
    required int total,
    required String paymentLabel,
    this.courierTitle = const Value.absent(),
    this.courierInfo = const Value.absent(),
    required String receiverName,
    required String receiverPhone,
    required String deliveryAddress,
    required String deliveryNote,
    required int createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        seller = Value(seller),
        dateLabel = Value(dateLabel),
        status = Value(status),
        total = Value(total),
        paymentLabel = Value(paymentLabel),
        receiverName = Value(receiverName),
        receiverPhone = Value(receiverPhone),
        deliveryAddress = Value(deliveryAddress),
        deliveryNote = Value(deliveryNote),
        createdAt = Value(createdAt);
  static Insertable<DbOrder> custom({
    Expression<String>? id,
    Expression<String>? seller,
    Expression<String>? dateLabel,
    Expression<String>? status,
    Expression<int>? total,
    Expression<String>? paymentLabel,
    Expression<String>? courierTitle,
    Expression<String>? courierInfo,
    Expression<String>? receiverName,
    Expression<String>? receiverPhone,
    Expression<String>? deliveryAddress,
    Expression<String>? deliveryNote,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (seller != null) 'seller': seller,
      if (dateLabel != null) 'date_label': dateLabel,
      if (status != null) 'status': status,
      if (total != null) 'total': total,
      if (paymentLabel != null) 'payment_label': paymentLabel,
      if (courierTitle != null) 'courier_title': courierTitle,
      if (courierInfo != null) 'courier_info': courierInfo,
      if (receiverName != null) 'receiver_name': receiverName,
      if (receiverPhone != null) 'receiver_phone': receiverPhone,
      if (deliveryAddress != null) 'delivery_address': deliveryAddress,
      if (deliveryNote != null) 'delivery_note': deliveryNote,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OrdersTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? seller,
      Value<String>? dateLabel,
      Value<String>? status,
      Value<int>? total,
      Value<String>? paymentLabel,
      Value<String?>? courierTitle,
      Value<String?>? courierInfo,
      Value<String>? receiverName,
      Value<String>? receiverPhone,
      Value<String>? deliveryAddress,
      Value<String>? deliveryNote,
      Value<int>? createdAt,
      Value<int>? rowid}) {
    return OrdersTableCompanion(
      id: id ?? this.id,
      seller: seller ?? this.seller,
      dateLabel: dateLabel ?? this.dateLabel,
      status: status ?? this.status,
      total: total ?? this.total,
      paymentLabel: paymentLabel ?? this.paymentLabel,
      courierTitle: courierTitle ?? this.courierTitle,
      courierInfo: courierInfo ?? this.courierInfo,
      receiverName: receiverName ?? this.receiverName,
      receiverPhone: receiverPhone ?? this.receiverPhone,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      deliveryNote: deliveryNote ?? this.deliveryNote,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (seller.present) {
      map['seller'] = Variable<String>(seller.value);
    }
    if (dateLabel.present) {
      map['date_label'] = Variable<String>(dateLabel.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (total.present) {
      map['total'] = Variable<int>(total.value);
    }
    if (paymentLabel.present) {
      map['payment_label'] = Variable<String>(paymentLabel.value);
    }
    if (courierTitle.present) {
      map['courier_title'] = Variable<String>(courierTitle.value);
    }
    if (courierInfo.present) {
      map['courier_info'] = Variable<String>(courierInfo.value);
    }
    if (receiverName.present) {
      map['receiver_name'] = Variable<String>(receiverName.value);
    }
    if (receiverPhone.present) {
      map['receiver_phone'] = Variable<String>(receiverPhone.value);
    }
    if (deliveryAddress.present) {
      map['delivery_address'] = Variable<String>(deliveryAddress.value);
    }
    if (deliveryNote.present) {
      map['delivery_note'] = Variable<String>(deliveryNote.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrdersTableCompanion(')
          ..write('id: $id, ')
          ..write('seller: $seller, ')
          ..write('dateLabel: $dateLabel, ')
          ..write('status: $status, ')
          ..write('total: $total, ')
          ..write('paymentLabel: $paymentLabel, ')
          ..write('courierTitle: $courierTitle, ')
          ..write('courierInfo: $courierInfo, ')
          ..write('receiverName: $receiverName, ')
          ..write('receiverPhone: $receiverPhone, ')
          ..write('deliveryAddress: $deliveryAddress, ')
          ..write('deliveryNote: $deliveryNote, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OrderItemsTableTable extends OrderItemsTable
    with TableInfo<$OrderItemsTableTable, DbOrderItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrderItemsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _orderIdMeta =
      const VerificationMeta('orderId');
  @override
  late final GeneratedColumn<String> orderId = GeneratedColumn<String>(
      'order_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES orders_table (id)'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _variantMeta =
      const VerificationMeta('variant');
  @override
  late final GeneratedColumn<String> variant = GeneratedColumn<String>(
      'variant', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<int> price = GeneratedColumn<int>(
      'price', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _qtyMeta = const VerificationMeta('qty');
  @override
  late final GeneratedColumn<int> qty = GeneratedColumn<int>(
      'qty', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _imageMeta = const VerificationMeta('image');
  @override
  late final GeneratedColumn<String> image = GeneratedColumn<String>(
      'image', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, orderId, name, variant, price, qty, image];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'order_items_table';
  @override
  VerificationContext validateIntegrity(Insertable<DbOrderItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('order_id')) {
      context.handle(_orderIdMeta,
          orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta));
    } else if (isInserting) {
      context.missing(_orderIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('variant')) {
      context.handle(_variantMeta,
          variant.isAcceptableOrUnknown(data['variant']!, _variantMeta));
    } else if (isInserting) {
      context.missing(_variantMeta);
    }
    if (data.containsKey('price')) {
      context.handle(
          _priceMeta, price.isAcceptableOrUnknown(data['price']!, _priceMeta));
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('qty')) {
      context.handle(
          _qtyMeta, qty.isAcceptableOrUnknown(data['qty']!, _qtyMeta));
    } else if (isInserting) {
      context.missing(_qtyMeta);
    }
    if (data.containsKey('image')) {
      context.handle(
          _imageMeta, image.isAcceptableOrUnknown(data['image']!, _imageMeta));
    } else if (isInserting) {
      context.missing(_imageMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbOrderItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbOrderItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      orderId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}order_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      variant: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}variant'])!,
      price: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}price'])!,
      qty: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}qty'])!,
      image: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image'])!,
    );
  }

  @override
  $OrderItemsTableTable createAlias(String alias) {
    return $OrderItemsTableTable(attachedDatabase, alias);
  }
}

class DbOrderItem extends DataClass implements Insertable<DbOrderItem> {
  final int id;
  final String orderId;
  final String name;
  final String variant;
  final int price;
  final int qty;
  final String image;
  const DbOrderItem(
      {required this.id,
      required this.orderId,
      required this.name,
      required this.variant,
      required this.price,
      required this.qty,
      required this.image});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['order_id'] = Variable<String>(orderId);
    map['name'] = Variable<String>(name);
    map['variant'] = Variable<String>(variant);
    map['price'] = Variable<int>(price);
    map['qty'] = Variable<int>(qty);
    map['image'] = Variable<String>(image);
    return map;
  }

  OrderItemsTableCompanion toCompanion(bool nullToAbsent) {
    return OrderItemsTableCompanion(
      id: Value(id),
      orderId: Value(orderId),
      name: Value(name),
      variant: Value(variant),
      price: Value(price),
      qty: Value(qty),
      image: Value(image),
    );
  }

  factory DbOrderItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbOrderItem(
      id: serializer.fromJson<int>(json['id']),
      orderId: serializer.fromJson<String>(json['orderId']),
      name: serializer.fromJson<String>(json['name']),
      variant: serializer.fromJson<String>(json['variant']),
      price: serializer.fromJson<int>(json['price']),
      qty: serializer.fromJson<int>(json['qty']),
      image: serializer.fromJson<String>(json['image']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'orderId': serializer.toJson<String>(orderId),
      'name': serializer.toJson<String>(name),
      'variant': serializer.toJson<String>(variant),
      'price': serializer.toJson<int>(price),
      'qty': serializer.toJson<int>(qty),
      'image': serializer.toJson<String>(image),
    };
  }

  DbOrderItem copyWith(
          {int? id,
          String? orderId,
          String? name,
          String? variant,
          int? price,
          int? qty,
          String? image}) =>
      DbOrderItem(
        id: id ?? this.id,
        orderId: orderId ?? this.orderId,
        name: name ?? this.name,
        variant: variant ?? this.variant,
        price: price ?? this.price,
        qty: qty ?? this.qty,
        image: image ?? this.image,
      );
  DbOrderItem copyWithCompanion(OrderItemsTableCompanion data) {
    return DbOrderItem(
      id: data.id.present ? data.id.value : this.id,
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      name: data.name.present ? data.name.value : this.name,
      variant: data.variant.present ? data.variant.value : this.variant,
      price: data.price.present ? data.price.value : this.price,
      qty: data.qty.present ? data.qty.value : this.qty,
      image: data.image.present ? data.image.value : this.image,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbOrderItem(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('name: $name, ')
          ..write('variant: $variant, ')
          ..write('price: $price, ')
          ..write('qty: $qty, ')
          ..write('image: $image')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, orderId, name, variant, price, qty, image);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbOrderItem &&
          other.id == this.id &&
          other.orderId == this.orderId &&
          other.name == this.name &&
          other.variant == this.variant &&
          other.price == this.price &&
          other.qty == this.qty &&
          other.image == this.image);
}

class OrderItemsTableCompanion extends UpdateCompanion<DbOrderItem> {
  final Value<int> id;
  final Value<String> orderId;
  final Value<String> name;
  final Value<String> variant;
  final Value<int> price;
  final Value<int> qty;
  final Value<String> image;
  const OrderItemsTableCompanion({
    this.id = const Value.absent(),
    this.orderId = const Value.absent(),
    this.name = const Value.absent(),
    this.variant = const Value.absent(),
    this.price = const Value.absent(),
    this.qty = const Value.absent(),
    this.image = const Value.absent(),
  });
  OrderItemsTableCompanion.insert({
    this.id = const Value.absent(),
    required String orderId,
    required String name,
    required String variant,
    required int price,
    required int qty,
    required String image,
  })  : orderId = Value(orderId),
        name = Value(name),
        variant = Value(variant),
        price = Value(price),
        qty = Value(qty),
        image = Value(image);
  static Insertable<DbOrderItem> custom({
    Expression<int>? id,
    Expression<String>? orderId,
    Expression<String>? name,
    Expression<String>? variant,
    Expression<int>? price,
    Expression<int>? qty,
    Expression<String>? image,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (orderId != null) 'order_id': orderId,
      if (name != null) 'name': name,
      if (variant != null) 'variant': variant,
      if (price != null) 'price': price,
      if (qty != null) 'qty': qty,
      if (image != null) 'image': image,
    });
  }

  OrderItemsTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? orderId,
      Value<String>? name,
      Value<String>? variant,
      Value<int>? price,
      Value<int>? qty,
      Value<String>? image}) {
    return OrderItemsTableCompanion(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      name: name ?? this.name,
      variant: variant ?? this.variant,
      price: price ?? this.price,
      qty: qty ?? this.qty,
      image: image ?? this.image,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (orderId.present) {
      map['order_id'] = Variable<String>(orderId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (variant.present) {
      map['variant'] = Variable<String>(variant.value);
    }
    if (price.present) {
      map['price'] = Variable<int>(price.value);
    }
    if (qty.present) {
      map['qty'] = Variable<int>(qty.value);
    }
    if (image.present) {
      map['image'] = Variable<String>(image.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrderItemsTableCompanion(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('name: $name, ')
          ..write('variant: $variant, ')
          ..write('price: $price, ')
          ..write('qty: $qty, ')
          ..write('image: $image')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProductsTableTable productsTable = $ProductsTableTable(this);
  late final $OrdersTableTable ordersTable = $OrdersTableTable(this);
  late final $OrderItemsTableTable orderItemsTable =
      $OrderItemsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [productsTable, ordersTable, orderItemsTable];
}

typedef $$ProductsTableTableCreateCompanionBuilder = ProductsTableCompanion
    Function({
  required String id,
  required String name,
  required String shortName,
  required String seller,
  required String category,
  required int price,
  required String unit,
  required String image,
  required double rating,
  required int stock,
  required int lastFetched,
  Value<int> rowid,
});
typedef $$ProductsTableTableUpdateCompanionBuilder = ProductsTableCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String> shortName,
  Value<String> seller,
  Value<String> category,
  Value<int> price,
  Value<String> unit,
  Value<String> image,
  Value<double> rating,
  Value<int> stock,
  Value<int> lastFetched,
  Value<int> rowid,
});

class $$ProductsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ProductsTableTable> {
  $$ProductsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get shortName => $composableBuilder(
      column: $table.shortName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get seller => $composableBuilder(
      column: $table.seller, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get image => $composableBuilder(
      column: $table.image, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get rating => $composableBuilder(
      column: $table.rating, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get stock => $composableBuilder(
      column: $table.stock, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastFetched => $composableBuilder(
      column: $table.lastFetched, builder: (column) => ColumnFilters(column));
}

class $$ProductsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductsTableTable> {
  $$ProductsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get shortName => $composableBuilder(
      column: $table.shortName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get seller => $composableBuilder(
      column: $table.seller, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get image => $composableBuilder(
      column: $table.image, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get rating => $composableBuilder(
      column: $table.rating, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get stock => $composableBuilder(
      column: $table.stock, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastFetched => $composableBuilder(
      column: $table.lastFetched, builder: (column) => ColumnOrderings(column));
}

class $$ProductsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductsTableTable> {
  $$ProductsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get shortName =>
      $composableBuilder(column: $table.shortName, builder: (column) => column);

  GeneratedColumn<String> get seller =>
      $composableBuilder(column: $table.seller, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get image =>
      $composableBuilder(column: $table.image, builder: (column) => column);

  GeneratedColumn<double> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<int> get stock =>
      $composableBuilder(column: $table.stock, builder: (column) => column);

  GeneratedColumn<int> get lastFetched => $composableBuilder(
      column: $table.lastFetched, builder: (column) => column);
}

class $$ProductsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProductsTableTable,
    ProductEntry,
    $$ProductsTableTableFilterComposer,
    $$ProductsTableTableOrderingComposer,
    $$ProductsTableTableAnnotationComposer,
    $$ProductsTableTableCreateCompanionBuilder,
    $$ProductsTableTableUpdateCompanionBuilder,
    (
      ProductEntry,
      BaseReferences<_$AppDatabase, $ProductsTableTable, ProductEntry>
    ),
    ProductEntry,
    PrefetchHooks Function()> {
  $$ProductsTableTableTableManager(_$AppDatabase db, $ProductsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> shortName = const Value.absent(),
            Value<String> seller = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<int> price = const Value.absent(),
            Value<String> unit = const Value.absent(),
            Value<String> image = const Value.absent(),
            Value<double> rating = const Value.absent(),
            Value<int> stock = const Value.absent(),
            Value<int> lastFetched = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProductsTableCompanion(
            id: id,
            name: name,
            shortName: shortName,
            seller: seller,
            category: category,
            price: price,
            unit: unit,
            image: image,
            rating: rating,
            stock: stock,
            lastFetched: lastFetched,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String shortName,
            required String seller,
            required String category,
            required int price,
            required String unit,
            required String image,
            required double rating,
            required int stock,
            required int lastFetched,
            Value<int> rowid = const Value.absent(),
          }) =>
              ProductsTableCompanion.insert(
            id: id,
            name: name,
            shortName: shortName,
            seller: seller,
            category: category,
            price: price,
            unit: unit,
            image: image,
            rating: rating,
            stock: stock,
            lastFetched: lastFetched,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$ProductsTableTable, ProductEntry>(table),
                    BaseReferences<_$AppDatabase, $ProductsTableTable,
                        ProductEntry>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ProductsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProductsTableTable,
    ProductEntry,
    $$ProductsTableTableFilterComposer,
    $$ProductsTableTableOrderingComposer,
    $$ProductsTableTableAnnotationComposer,
    $$ProductsTableTableCreateCompanionBuilder,
    $$ProductsTableTableUpdateCompanionBuilder,
    (
      ProductEntry,
      BaseReferences<_$AppDatabase, $ProductsTableTable, ProductEntry>
    ),
    ProductEntry,
    PrefetchHooks Function()>;
typedef $$OrdersTableTableCreateCompanionBuilder = OrdersTableCompanion
    Function({
  required String id,
  required String seller,
  required String dateLabel,
  required String status,
  required int total,
  required String paymentLabel,
  Value<String?> courierTitle,
  Value<String?> courierInfo,
  required String receiverName,
  required String receiverPhone,
  required String deliveryAddress,
  required String deliveryNote,
  required int createdAt,
  Value<int> rowid,
});
typedef $$OrdersTableTableUpdateCompanionBuilder = OrdersTableCompanion
    Function({
  Value<String> id,
  Value<String> seller,
  Value<String> dateLabel,
  Value<String> status,
  Value<int> total,
  Value<String> paymentLabel,
  Value<String?> courierTitle,
  Value<String?> courierInfo,
  Value<String> receiverName,
  Value<String> receiverPhone,
  Value<String> deliveryAddress,
  Value<String> deliveryNote,
  Value<int> createdAt,
  Value<int> rowid,
});

final class $$OrdersTableTableReferences
    extends BaseReferences<_$AppDatabase, $OrdersTableTable, DbOrder> {
  $$OrdersTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$OrderItemsTableTable, List<DbOrderItem>>
      _orderItemsTableRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.orderItemsTable,
              aliasName: 'orders_table__id__order_items_table__order_id');

  $$OrderItemsTableTableProcessedTableManager get orderItemsTableRefs {
    final manager =
        $$OrderItemsTableTableTableManager($_db, $_db.orderItemsTable)
            .filter((f) => f.orderId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_orderItemsTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$OrdersTableTableFilterComposer
    extends Composer<_$AppDatabase, $OrdersTableTable> {
  $$OrdersTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get seller => $composableBuilder(
      column: $table.seller, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dateLabel => $composableBuilder(
      column: $table.dateLabel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get total => $composableBuilder(
      column: $table.total, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paymentLabel => $composableBuilder(
      column: $table.paymentLabel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get courierTitle => $composableBuilder(
      column: $table.courierTitle, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get courierInfo => $composableBuilder(
      column: $table.courierInfo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get receiverName => $composableBuilder(
      column: $table.receiverName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get receiverPhone => $composableBuilder(
      column: $table.receiverPhone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deliveryAddress => $composableBuilder(
      column: $table.deliveryAddress,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deliveryNote => $composableBuilder(
      column: $table.deliveryNote, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> orderItemsTableRefs(
      Expression<bool> Function($$OrderItemsTableTableFilterComposer f) f) {
    final $$OrderItemsTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.orderItemsTable,
        getReferencedColumn: (t) => t.orderId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrderItemsTableTableFilterComposer(
              $db: $db,
              $table: $db.orderItemsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$OrdersTableTableOrderingComposer
    extends Composer<_$AppDatabase, $OrdersTableTable> {
  $$OrdersTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get seller => $composableBuilder(
      column: $table.seller, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dateLabel => $composableBuilder(
      column: $table.dateLabel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get total => $composableBuilder(
      column: $table.total, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paymentLabel => $composableBuilder(
      column: $table.paymentLabel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get courierTitle => $composableBuilder(
      column: $table.courierTitle,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get courierInfo => $composableBuilder(
      column: $table.courierInfo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get receiverName => $composableBuilder(
      column: $table.receiverName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get receiverPhone => $composableBuilder(
      column: $table.receiverPhone,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deliveryAddress => $composableBuilder(
      column: $table.deliveryAddress,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deliveryNote => $composableBuilder(
      column: $table.deliveryNote,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$OrdersTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrdersTableTable> {
  $$OrdersTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get seller =>
      $composableBuilder(column: $table.seller, builder: (column) => column);

  GeneratedColumn<String> get dateLabel =>
      $composableBuilder(column: $table.dateLabel, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<String> get paymentLabel => $composableBuilder(
      column: $table.paymentLabel, builder: (column) => column);

  GeneratedColumn<String> get courierTitle => $composableBuilder(
      column: $table.courierTitle, builder: (column) => column);

  GeneratedColumn<String> get courierInfo => $composableBuilder(
      column: $table.courierInfo, builder: (column) => column);

  GeneratedColumn<String> get receiverName => $composableBuilder(
      column: $table.receiverName, builder: (column) => column);

  GeneratedColumn<String> get receiverPhone => $composableBuilder(
      column: $table.receiverPhone, builder: (column) => column);

  GeneratedColumn<String> get deliveryAddress => $composableBuilder(
      column: $table.deliveryAddress, builder: (column) => column);

  GeneratedColumn<String> get deliveryNote => $composableBuilder(
      column: $table.deliveryNote, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> orderItemsTableRefs<T extends Object>(
      Expression<T> Function($$OrderItemsTableTableAnnotationComposer a) f) {
    final $$OrderItemsTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.orderItemsTable,
        getReferencedColumn: (t) => t.orderId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrderItemsTableTableAnnotationComposer(
              $db: $db,
              $table: $db.orderItemsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$OrdersTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OrdersTableTable,
    DbOrder,
    $$OrdersTableTableFilterComposer,
    $$OrdersTableTableOrderingComposer,
    $$OrdersTableTableAnnotationComposer,
    $$OrdersTableTableCreateCompanionBuilder,
    $$OrdersTableTableUpdateCompanionBuilder,
    (DbOrder, $$OrdersTableTableReferences),
    DbOrder,
    PrefetchHooks Function({bool orderItemsTableRefs})> {
  $$OrdersTableTableTableManager(_$AppDatabase db, $OrdersTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrdersTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrdersTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrdersTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> seller = const Value.absent(),
            Value<String> dateLabel = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> total = const Value.absent(),
            Value<String> paymentLabel = const Value.absent(),
            Value<String?> courierTitle = const Value.absent(),
            Value<String?> courierInfo = const Value.absent(),
            Value<String> receiverName = const Value.absent(),
            Value<String> receiverPhone = const Value.absent(),
            Value<String> deliveryAddress = const Value.absent(),
            Value<String> deliveryNote = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OrdersTableCompanion(
            id: id,
            seller: seller,
            dateLabel: dateLabel,
            status: status,
            total: total,
            paymentLabel: paymentLabel,
            courierTitle: courierTitle,
            courierInfo: courierInfo,
            receiverName: receiverName,
            receiverPhone: receiverPhone,
            deliveryAddress: deliveryAddress,
            deliveryNote: deliveryNote,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String seller,
            required String dateLabel,
            required String status,
            required int total,
            required String paymentLabel,
            Value<String?> courierTitle = const Value.absent(),
            Value<String?> courierInfo = const Value.absent(),
            required String receiverName,
            required String receiverPhone,
            required String deliveryAddress,
            required String deliveryNote,
            required int createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              OrdersTableCompanion.insert(
            id: id,
            seller: seller,
            dateLabel: dateLabel,
            status: status,
            total: total,
            paymentLabel: paymentLabel,
            courierTitle: courierTitle,
            courierInfo: courierInfo,
            receiverName: receiverName,
            receiverPhone: receiverPhone,
            deliveryAddress: deliveryAddress,
            deliveryNote: deliveryNote,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$OrdersTableTable, DbOrder>(table),
                    $$OrdersTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({orderItemsTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (orderItemsTableRefs) db.orderItemsTable
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (orderItemsTableRefs)
                    await $_getPrefetchedData<DbOrder, $OrdersTableTable,
                            DbOrderItem>(
                        currentTable: table,
                        referencedTable: $$OrdersTableTableReferences
                            ._orderItemsTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$OrdersTableTableReferences(db, table, p0)
                                .orderItemsTableRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.orderId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$OrdersTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OrdersTableTable,
    DbOrder,
    $$OrdersTableTableFilterComposer,
    $$OrdersTableTableOrderingComposer,
    $$OrdersTableTableAnnotationComposer,
    $$OrdersTableTableCreateCompanionBuilder,
    $$OrdersTableTableUpdateCompanionBuilder,
    (DbOrder, $$OrdersTableTableReferences),
    DbOrder,
    PrefetchHooks Function({bool orderItemsTableRefs})>;
typedef $$OrderItemsTableTableCreateCompanionBuilder = OrderItemsTableCompanion
    Function({
  Value<int> id,
  required String orderId,
  required String name,
  required String variant,
  required int price,
  required int qty,
  required String image,
});
typedef $$OrderItemsTableTableUpdateCompanionBuilder = OrderItemsTableCompanion
    Function({
  Value<int> id,
  Value<String> orderId,
  Value<String> name,
  Value<String> variant,
  Value<int> price,
  Value<int> qty,
  Value<String> image,
});

final class $$OrderItemsTableTableReferences
    extends BaseReferences<_$AppDatabase, $OrderItemsTableTable, DbOrderItem> {
  $$OrderItemsTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $OrdersTableTable _orderIdTable(_$AppDatabase db) => db.ordersTable
      .createAlias('order_items_table__order_id__orders_table__id');

  $$OrdersTableTableProcessedTableManager get orderId {
    final $_column = $_itemColumn<String>('order_id')!;

    final manager = $$OrdersTableTableTableManager($_db, $_db.ordersTable)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_orderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$OrderItemsTableTableFilterComposer
    extends Composer<_$AppDatabase, $OrderItemsTableTable> {
  $$OrderItemsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get variant => $composableBuilder(
      column: $table.variant, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get qty => $composableBuilder(
      column: $table.qty, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get image => $composableBuilder(
      column: $table.image, builder: (column) => ColumnFilters(column));

  $$OrdersTableTableFilterComposer get orderId {
    final $$OrdersTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.orderId,
        referencedTable: $db.ordersTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrdersTableTableFilterComposer(
              $db: $db,
              $table: $db.ordersTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$OrderItemsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $OrderItemsTableTable> {
  $$OrderItemsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get variant => $composableBuilder(
      column: $table.variant, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get qty => $composableBuilder(
      column: $table.qty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get image => $composableBuilder(
      column: $table.image, builder: (column) => ColumnOrderings(column));

  $$OrdersTableTableOrderingComposer get orderId {
    final $$OrdersTableTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.orderId,
        referencedTable: $db.ordersTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrdersTableTableOrderingComposer(
              $db: $db,
              $table: $db.ordersTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$OrderItemsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrderItemsTableTable> {
  $$OrderItemsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get variant =>
      $composableBuilder(column: $table.variant, builder: (column) => column);

  GeneratedColumn<int> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<int> get qty =>
      $composableBuilder(column: $table.qty, builder: (column) => column);

  GeneratedColumn<String> get image =>
      $composableBuilder(column: $table.image, builder: (column) => column);

  $$OrdersTableTableAnnotationComposer get orderId {
    final $$OrdersTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.orderId,
        referencedTable: $db.ordersTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrdersTableTableAnnotationComposer(
              $db: $db,
              $table: $db.ordersTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$OrderItemsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OrderItemsTableTable,
    DbOrderItem,
    $$OrderItemsTableTableFilterComposer,
    $$OrderItemsTableTableOrderingComposer,
    $$OrderItemsTableTableAnnotationComposer,
    $$OrderItemsTableTableCreateCompanionBuilder,
    $$OrderItemsTableTableUpdateCompanionBuilder,
    (DbOrderItem, $$OrderItemsTableTableReferences),
    DbOrderItem,
    PrefetchHooks Function({bool orderId})> {
  $$OrderItemsTableTableTableManager(
      _$AppDatabase db, $OrderItemsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrderItemsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrderItemsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrderItemsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> orderId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> variant = const Value.absent(),
            Value<int> price = const Value.absent(),
            Value<int> qty = const Value.absent(),
            Value<String> image = const Value.absent(),
          }) =>
              OrderItemsTableCompanion(
            id: id,
            orderId: orderId,
            name: name,
            variant: variant,
            price: price,
            qty: qty,
            image: image,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String orderId,
            required String name,
            required String variant,
            required int price,
            required int qty,
            required String image,
          }) =>
              OrderItemsTableCompanion.insert(
            id: id,
            orderId: orderId,
            name: name,
            variant: variant,
            price: price,
            qty: qty,
            image: image,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$OrderItemsTableTable, DbOrderItem>(table),
                    $$OrderItemsTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({orderId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (orderId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.orderId,
                    referencedTable:
                        $$OrderItemsTableTableReferences._orderIdTable(db),
                    referencedColumn:
                        $$OrderItemsTableTableReferences._orderIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$OrderItemsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OrderItemsTableTable,
    DbOrderItem,
    $$OrderItemsTableTableFilterComposer,
    $$OrderItemsTableTableOrderingComposer,
    $$OrderItemsTableTableAnnotationComposer,
    $$OrderItemsTableTableCreateCompanionBuilder,
    $$OrderItemsTableTableUpdateCompanionBuilder,
    (DbOrderItem, $$OrderItemsTableTableReferences),
    DbOrderItem,
    PrefetchHooks Function({bool orderId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProductsTableTableTableManager get productsTable =>
      $$ProductsTableTableTableManager(_db, _db.productsTable);
  $$OrdersTableTableTableManager get ordersTable =>
      $$OrdersTableTableTableManager(_db, _db.ordersTable);
  $$OrderItemsTableTableTableManager get orderItemsTable =>
      $$OrderItemsTableTableTableManager(_db, _db.orderItemsTable);
}
