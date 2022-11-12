import 'package:flutter/material.dart';
import 'package:sixam_mart/util/dimensions.dart';

class PaginatedListView extends StatefulWidget {
  final ScrollController scrollController;
  final Function(int offset) onPaginate;
  final int totalSize;
  final int offset;
  final Widget itemView;
  const PaginatedListView({
    Key key, @required this.scrollController, @required this.onPaginate, @required this.totalSize,
    @required this.offset, @required this.itemView,
  }) : super(key: key);

  @override
  State<PaginatedListView> createState() => _PaginatedListViewState();
}

class _PaginatedListViewState extends State<PaginatedListView> {
  int _offset;
  List<int> _offsetList;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _offset = 1;
    _offsetList = [1];

    widget.scrollController?.addListener(() async {
      if (widget.scrollController.position.pixels == widget.scrollController.position.maxScrollExtent
          && widget.totalSize != null && !_isLoading) {
        int pageSize = (widget.totalSize / 10).ceil();
        if (_offset < pageSize && !_offsetList.contains(_offset+1)) {

          setState(() {
            _offset++;
            _offsetList.add(_offset);
            _isLoading = true;
          });
          await widget.onPaginate(_offset);
          setState(() {
            _isLoading = false;
          });

        }else {
          if(_isLoading) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();

    widget.scrollController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(widget.offset != null && widget.offset == 1) {
      _offset = 1;
      _offsetList = [1];
    }

    return Column(children: [

      widget.itemView,

      _isLoading ? Center(child: Padding(
        padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)),
      )) : SizedBox(),

    ]);
  }
}
